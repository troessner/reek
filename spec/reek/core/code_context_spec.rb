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
      @ctx.name.should == @exp_name
    end
    it 'does not match an empty list' do
      @ctx.matches?([]).should == false
    end
    it 'does not match when its own short name is not given' do
      @ctx.matches?(['banana']).should == false
    end
    it 'recognises its own short name' do
      @ctx.matches?(['banana', @exp_name]).should == true
    end
    it 'recognises its short name as a regex' do
      @ctx.matches?([/banana/, /#{@exp_name}/]).should == true
    end

    context 'when there is an outer' do
      before :each do
        @outer_name = 'another_random sting'
        outer = double('outer')
        outer.should_receive(:full_name).at_least(:once).and_return(@outer_name)
        outer.should_receive(:config).and_return({})
        @ctx = CodeContext.new(outer, @exp)
      end
      it 'creates the correct full name' do
        @ctx.full_name.should == "#{@full_name}"
      end
      it 'recognises its own full name' do
        @ctx.matches?(['banana', @full_name]).should == true
      end
      it 'recognises its full name as a regex' do
        @ctx.matches?([/banana/, /#{@full_name}/]).should == true
      end
    end
  end

  context 'generics' do
    it 'should pass unknown method calls down the stack' do
      stop = StopContext.new
      def stop.bananas(arg1, arg2) arg1 + arg2 + 43 end
      element = ModuleContext.new(stop, 'mod', ast(:module, :mod, nil))
      element = MethodContext.new(element, ast(:defn, :bad))
      element.bananas(17, -5).should == 55
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
        @ctx.each_node(:call, []) {|exp| raise "#{exp} yielded by empty module!"}
      end
      it 'yields one module' do
        mods = 0
        @ctx.each_node(:module, []) {|exp| mods += 1}
        mods.should == 1
      end
      it "yields the module's full AST" do
        @ctx.each_node(:module, []) {|exp| exp[1].should == @module_name.to_sym}
      end

      context 'with no block' do
        it 'returns an empty array of ifs' do
          @ctx.each_node(:if, []).should be_empty
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
        @ctx.each_node(:if, []) {|exp| raise "#{exp} yielded by empty module!"}
      end
      it 'yields one module' do
        @ctx.each_node(:module, []).length.should == 1
      end
      it "yields the module's full AST" do
        @ctx.each_node(:module, []) {|exp| exp[1].should == @module_name.to_sym}
      end
      it 'yields one method' do
        @ctx.each_node(:defn, []).length.should == 1
      end
      it "yields the method's full AST" do
        @ctx.each_node(:defn, []) {|exp| exp[1].should == @method_name.to_sym}
      end

      context 'pruning the traversal' do
        it 'ignores the call inside the method' do
          @ctx.each_node(:call, [:defn]).should be_empty
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
      ctx.each_node(:if, []).length.should == 3
    end
  end
end
