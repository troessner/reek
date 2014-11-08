require 'spec_helper'
require 'reek/smells/repeated_conditional'
require 'reek/core/code_context'
require 'reek/smells/smell_detector_shared'

include Reek::Core
include Reek::Smells

describe RepeatedConditional do
  before :each do
    @source_name = 'howdy-doody'
    @detector = RepeatedConditional.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'with no conditionals' do
    it 'gathers an empty hash' do
      ast = 'module Stable; end'.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      expect(@detector.conditional_counts(ctx).length).to eq(0)
    end
  end

  context 'with a test of block_given?' do
    it 'does not record the condition' do
      ast = 'def fred() yield(3) if block_given?; end'.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      expect(@detector.conditional_counts(ctx).length).to eq(0)
    end
  end

  context 'with an empty condition' do
    it 'does not record the condition' do
      ast = 'def fred() case; when 3; end; end'.to_reek_source.syntax_tree
      ctx = CodeContext.new(nil, ast)
      expect(@detector.conditional_counts(ctx).length).to eq(0)
    end
  end

  context 'with three identical conditionals' do
    before :each do
      @cond = '@field == :sym'
      @cond_expr = @cond.to_reek_source.syntax_tree
      src = <<EOS
class Scrunch
  def first
    puts "hello" if @debug
    return #{@cond} ? 0 : 3;
  end
  def second
    if #{@cond}
      @other += " quarts"
    end
  end
  def third
    raise 'flu!' unless #{@cond}
  end
end
EOS

      ast = src.to_reek_source.syntax_tree
      @ctx = CodeContext.new(nil, ast)
      @conds = @detector.conditional_counts(@ctx)
    end

    it 'finds both conditionals' do
      expect(@conds.length).to eq(2)
    end

    it 'returns the condition expr' do
      expect(@conds.keys[1]).to eq(@cond_expr)
    end

    it 'knows there are three copies' do
      expect(@conds.values[1].length).to eq(3)
    end

    context 'looking at the YAML' do
      before :each do
        @detector.examine(@ctx)
        warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
        @yaml = warning.to_yaml
      end
      it 'reports the source' do
        expect(@yaml).to match(/source:\s*#{@source_name}/)
      end
      it 'reports the class' do
        expect(@yaml).to match(/class:\s*SimulatedPolymorphism/)
      end
      it 'reports the subclass' do
        expect(@yaml).to match(/subclass:\s*RepeatedConditional/)
      end
      it 'reports the expression' do
        expect(@yaml).to match(/expression:\s*(! )?['"]?#{@cond}["']?/)
      end
      it 'reports the number of occurrences' do
        expect(@yaml).to match(/occurrences:\s*3/)
      end
      it 'reports the referring lines' do
        expect(@yaml).to match(/lines:\s*- 4\s*- 7\s*- 12/)
      end
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
      expect(@conds.length).to eq(1)
    end
    it 'returns the condition expr' do
      expect(@conds.keys[0]).to eq(@cond_expr)
    end
    it 'knows there are two copies' do
      expect(@conds.values[0].length).to eq(2)
    end
  end

  # And count code in superclasses, if we have it
end
