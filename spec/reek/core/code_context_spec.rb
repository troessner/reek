require 'spec_helper'
require 'reek/core/method_context'
require 'reek/core/module_context'
require 'reek/core/stop_context'

include Reek::Core

describe CodeContext do
  context 'name recognition' do
    before :each do
      @exp_name = 'random_name'    # SMELL: could use a String.random here
      @full_name = "::::::::::::::::::::#{@exp_name}"
      @exp = double('exp')
      allow(@exp).to receive(:name).and_return(@exp_name)
      allow(@exp).to receive(:full_name).and_return(@full_name)
      allow(@exp).to receive(:comments).and_return('')
      @ctx = CodeContext.new(nil, @exp)
    end
    it 'gets its short name from the exp' do
      expect(@ctx.name).to eq(@exp_name)
    end
    it 'does not match an empty list' do
      expect(@ctx.matches?([])).to eq(false)
    end
    it 'does not match when its own short name is not given' do
      expect(@ctx.matches?(['banana'])).to eq(false)
    end
    it 'recognises its own short name' do
      expect(@ctx.matches?(['banana', @exp_name])).to eq(true)
    end
    it 'recognises its short name as a regex' do
      expect(@ctx.matches?([/banana/, /#{@exp_name}/])).to eq(true)
    end

    context 'when there is an outer' do
      before :each do
        @outer_name = 'another_random sting'
        outer = double('outer')
        allow(outer).to receive(:full_name).at_least(:once).and_return(@outer_name)
        allow(outer).to receive(:config).and_return({})
        @ctx = CodeContext.new(outer, @exp)
      end
      it 'creates the correct full name' do
        expect(@ctx.full_name).to eq("#{@full_name}")
      end
      it 'recognises its own full name' do
        expect(@ctx.matches?(['banana', @full_name])).to eq(true)
      end
      it 'recognises its full name as a regex' do
        expect(@ctx.matches?([/banana/, /#{@full_name}/])).to eq(true)
      end
    end
  end

  context 'generics' do
    it 'should pass unknown method calls down the stack' do
      stop = StopContext.new
      def stop.bananas(arg1, arg2) arg1 + arg2 + 43 end
      element = ModuleContext.new(stop, s(:module, :mod, nil))
      element = MethodContext.new(element, s(:def, :bad, s(:args), nil))
      expect(element.bananas(17, -5)).to eq(55)
    end
  end

  context 'enumerating syntax elements' do
    context 'in an empty module' do
      before :each do
        @module_name = 'Emptiness'
        src = "module #{@module_name}; end"
        ast = src.to_reek_source.syntax_tree
        @ctx = CodeContext.new(nil, ast)
      end

      it 'yields no calls' do
        @ctx.each_node(:send, []) { |exp| raise "#{exp} yielded by empty module!" }
      end

      it 'yields one module' do
        mods = 0
        @ctx.each_node(:module, []) { |_exp| mods += 1 }
        expect(mods).to eq(1)
      end

      it "yields the module's full AST" do
        @ctx.each_node(:module, []) do |exp|
          expect(exp).to eq(s(:module, s(:const, nil, @module_name.to_sym), nil))
        end
      end

      context 'with no block' do
        it 'returns an empty array of ifs' do
          expect(@ctx.each_node(:if, [])).to be_empty
        end
      end
    end

    context 'with a nested element' do
      before :each do
        @module_name = 'Loneliness'
        @method_name = 'calloo'
        src = "module #{@module_name}; def #{@method_name}; puts('hello') end; end"
        ast = src.to_reek_source.syntax_tree
        @ctx = CodeContext.new(nil, ast)
      end
      it 'yields no ifs' do
        @ctx.each_node(:if, []) { |exp| raise "#{exp} yielded by empty module!" }
      end
      it 'yields one module' do
        expect(@ctx.each_node(:module, []).length).to eq(1)
      end

      it "yields the module's full AST" do
        @ctx.each_node(:module, []) do |exp|
          expect(exp).to eq s(:module,
                              s(:const, nil, @module_name.to_sym),
                              s(:def, :calloo,
                                s(:args),
                                s(:send, nil, :puts, s(:str, 'hello'))))
        end
      end

      it 'yields one method' do
        expect(@ctx.each_node(:def, []).length).to eq(1)
      end

      it "yields the method's full AST" do
        @ctx.each_node(:def, []) { |exp| expect(exp[1]).to eq(@method_name.to_sym) }
      end

      context 'pruning the traversal' do
        it 'ignores the call inside the method' do
          expect(@ctx.each_node(:send, [:def])).to be_empty
        end
      end
    end

    it 'finds 3 ifs in a class' do
      src = <<EOS
class Scrunch
  def first
    return @field == :sym ? 0 : 3;
  end
  def second
    if @field == :sym
      @other += " quarts"
    end
  end
  def third
    raise 'flu!' unless @field == :sym
  end
end
EOS

      ast = src.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      expect(ctx.each_node(:if, []).length).to eq(3)
    end
  end

  describe '#config_for' do
    let(:exp) { double('exp') }
    let(:outer) { nil }
    let(:ctx) { CodeContext.new(outer, exp) }
    let(:sniffer) { double('sniffer') }

    before :each do
      allow(sniffer).to receive(:smell_type).and_return('DuplicateMethodCall')
      allow(exp).to receive(:comments).and_return(
        ':reek:DuplicateMethodCall: { allow_calls: [ puts ] }')
    end

    it 'gets its configuration from the exp comments' do
      expect(ctx.config_for(sniffer)).to eq('allow_calls' => ['puts'])
    end

    context 'when there is an outer' do
      let(:outer) { double('outer') }

      before :each do
        allow(outer).to receive(:config_for).with(sniffer).and_return(
          'max_calls' => 2)
      end

      it 'merges the outer config with its own configuration' do
        expect(ctx.config_for(sniffer)).to eq('allow_calls' => ['puts'],
                                              'max_calls' => 2)
      end
    end
  end
end
