require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/repeated_conditional'
require_relative '../../../lib/reek/core/code_context'
require_relative 'smell_detector_shared'
require_relative '../../../lib/reek/source/source_code'

RSpec.describe Reek::Smells::RepeatedConditional do
  before(:each) do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :RepeatedConditional, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'with no conditionals' do
    it 'gathers an empty hash' do
      ast = Reek::Source::SourceCode.from('module Stable; end').syntax_tree
      ctx = Reek::Core::CodeContext.new(nil, ast)
      expect(@detector.conditional_counts(ctx).length).to eq(0)
    end
  end

  context 'with a test of block_given?' do
    it 'does not record the condition' do
      ast = Reek::Source::SourceCode.from('def fred() yield(3) if block_given?; end').syntax_tree
      ctx = Reek::Core::CodeContext.new(nil, ast)
      expect(@detector.conditional_counts(ctx).length).to eq(0)
    end
  end

  context 'with an empty condition' do
    it 'does not record the condition' do
      ast = Reek::Source::SourceCode.from('def fred() case; when 3; end; end').syntax_tree
      ctx = Reek::Core::CodeContext.new(nil, ast)
      expect(@detector.conditional_counts(ctx).length).to eq(0)
    end
  end

  context 'with three identical conditionals' do
    before :each do
      @cond = '@field == :sym'
      @cond_expr = Reek::Source::SourceCode.from(@cond).syntax_tree
      src = <<-EOS
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

      ast = Reek::Source::SourceCode.from(src).syntax_tree
      @ctx = Reek::Core::CodeContext.new(nil, ast)
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
  end

  context 'with a matching if and case' do
    before :each do
      cond = '@field == :sym'
      @cond_expr = Reek::Source::SourceCode.from(cond).syntax_tree
      src = <<-EOS
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

      ast = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Core::CodeContext.new(nil, ast)
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
end
