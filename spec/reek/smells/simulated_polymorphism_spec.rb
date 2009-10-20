require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/simulated_polymorphism'
require 'reek/code_context'

include Reek
include Reek::Smells

describe SimulatedPolymorphism do
  before :each do
    @detector = SimulatedPolymorphism.new
  end
  context 'with no conditionals' do
    it 'gathers an empty hash' do
      ast = 'module Stable; end'.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      @detector.conditional_counts(ctx).length.should == 0
    end
  end

  context 'with a test of block_given?' do
    it 'does not record the condition' do
      ast = 'def fred() yield(3) if block_given?; end'.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      @detector.conditional_counts(ctx).length.should == 0
    end
  end

  context 'with three identical conditionals' do
    before :each do
      cond = '@field == :sym'
      @cond_expr = cond.to_reek_source.syntax_tree
      src = <<EOS
class Scrunch
  def first
    return #{cond} ? 0 : 3;
  end
  def second
    if #{cond}
      @other += " quarts"
    end
  end
  def third
    raise 'flu!' unless #{cond}
  end
end
EOS

      ast = src.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      @conds = @detector.conditional_counts(ctx)
    end
    it 'finds one matching conditional' do
      @conds.length.should == 1
    end
    it 'returns the condition expr' do
      @conds.keys[0].should == @cond_expr
    end
    it 'knows there are three copies' do
      @conds[@cond_expr].should == 3
    end
  end

  context 'with a matching if and case' do
    before :each do
      cond = '@field == :sym'
      @cond_expr = cond.to_reek_source.syntax_tree
      src = <<EOS
class Scrunch
  def alpha
    return #{cond} ? 0 : 2;
  end
  def beta
    case #{cond}
    when :symbol
      @tother += " pints"
    end
  end
end
EOS

      ast = src.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      @conds = @detector.conditional_counts(ctx)
    end
    it 'finds exactly one conditional' do
      @conds.length.should == 1
    end
    it 'returns the condition expr' do
      @conds.keys[0].should == @cond_expr
    end
    it 'knows there are three copies' do
      @conds[@cond_expr].should == 2
    end
  end

  # And count code in superclasses, if we have it
end
