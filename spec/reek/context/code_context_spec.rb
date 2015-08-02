require_relative '../../spec_helper'
require_relative '../../../lib/reek/context/method_context'
require_relative '../../../lib/reek/context/module_context'

RSpec.describe Reek::Context::CodeContext do
  context 'name recognition' do
    before :each do
      @exp_name = 'random_name' # SMELL: could use a String.random here
      @full_name = "::::::::::::::::::::#{@exp_name}"
      @exp = double('exp')
      allow(@exp).to receive(:name).and_return(@exp_name)
      allow(@exp).to receive(:full_name).and_return(@full_name)
      @ctx = Reek::Context::CodeContext.new(nil, @exp)
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
    it 'does not let pipe-ended Strings make matching ignore the rest' do
      expect(@ctx.matches?(['banana|'])).to eq(false)
    end
    it 'recognises its own short name' do
      expect(@ctx.matches?(['banana', @exp_name])).to eq(true)
    end
    it 'recognises its short name as a regex' do
      expect(@ctx.matches?([/banana/, /#{@exp_name}/])).to eq(true)
    end
    it 'does not blow up on []-ended Strings' do
      expect(@ctx.matches?(['banana[]', @exp_name])).to eq(true)
    end

    context 'when there is an outer' do
      let(:outer) { double('outer') }
      before :each do
        @outer_name = 'another_random sting'
        allow(outer).to receive(:full_name).at_least(:once).and_return(@outer_name)
        allow(outer).to receive(:config).and_return({})
        @ctx = Reek::Context::CodeContext.new(outer, @exp)
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

  context 'enumerating syntax elements' do
    context 'in an empty module' do
      before :each do
        @module_name = 'Emptiness'
        src = "module #{@module_name}; end"
        ast = Reek::Source::SourceCode.from(src).syntax_tree
        @ctx = Reek::Context::CodeContext.new(nil, ast)
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
        ast = Reek::Source::SourceCode.from(src).syntax_tree
        @ctx = Reek::Context::CodeContext.new(nil, ast)
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

      ast = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Context::CodeContext.new(nil, ast)
      expect(ctx.each_node(:if, []).length).to eq(3)
    end
  end

  describe '#config_for' do
    let(:src) do
      <<-EOS
      # :reek:DuplicateMethodCall: { allow_calls: [ puts ] }')
      def repeated_greeting
        puts 'Hello!'
        puts 'Hello!'
      end
      EOS
    end
    let(:expression) { Reek::Source::SourceCode.from(src).syntax_tree }
    let(:outer) { nil }
    let(:context) { Reek::Context::CodeContext.new(outer, expression) }
    let(:sniffer) { double('sniffer') }

    before :each do
      allow(sniffer).to receive(:smell_type).and_return('DuplicateMethodCall')
    end

    context 'when there is no outer context' do
      it 'gets its configuration from the expression comments' do
        expect(context.config_for(sniffer)).to eq('allow_calls' => ['puts'])
      end
    end

    context 'when there is an outer context' do
      let(:outer) { double('outer') }

      before :each do
        allow(outer).to receive(:config_for).with(sniffer).and_return(
          'max_calls' => 2)
      end

      it 'merges the outer config with its own configuration' do
        expect(context.config_for(sniffer)).to eq('allow_calls' => ['puts'],
                                                  'max_calls' => 2)
      end
    end
  end

  describe '#append_child_context' do
    let(:context) { Reek::Context::CodeContext.new(nil, double('exp1')) }
    let(:first_child) { Reek::Context::CodeContext.new(context, double('exp2')) }
    let(:second_child) { Reek::Context::CodeContext.new(context, double('exp3')) }

    it 'appends the child to the list of children' do
      context.append_child_context first_child
      context.append_child_context second_child
      expect(context.children).to eq [first_child, second_child]
    end
  end

  describe '#track_visibility' do
    let(:context) { Reek::Context::CodeContext.new(nil, double('exp1')) }
    let(:first_child) { Reek::Context::CodeContext.new(context, double('exp2', name: :foo)) }
    let(:second_child) { Reek::Context::CodeContext.new(context, double('exp3')) }

    it 'sets visibility on subsequent child contexts' do
      context.append_child_context first_child
      context.track_visibility :private
      context.append_child_context second_child
      expect(first_child.visibility).to eq :public
      expect(second_child.visibility).to eq :private
    end

    it 'sets visibility on specifically mentioned child contexts' do
      context.append_child_context first_child
      context.track_visibility :private, [first_child.name]
      context.append_child_context second_child
      expect(first_child.visibility).to eq :private
      expect(second_child.visibility).to eq :public
    end
  end

  describe '#each' do
    let(:context) { Reek::Context::CodeContext.new(nil, double('exp1')) }
    let(:first_child) { Reek::Context::CodeContext.new(context, double('exp2')) }
    let(:second_child) { Reek::Context::CodeContext.new(context, double('exp3')) }

    it 'yields each child' do
      context.append_child_context first_child
      context.append_child_context second_child
      result = []
      context.each do |ctx|
        result << ctx
      end

      expect(result).to eq [context, first_child, second_child]
    end
  end
end
