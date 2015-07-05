require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/duplicate_method_call'
require_relative '../../../lib/reek/context/code_context'
require_relative '../../../lib/reek/tree_walker'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::DuplicateMethodCall do
  context 'when a smell is reported' do
    before :each do
      @source_name = 'dummy_source'
      @detector = build(:smell_detector, smell_type: :DuplicateMethodCall, source: @source_name)
      src = <<-EOS
        def double_thing(other)
          other[@thing]
          not_the_sam(at = all)
          other[@thing]
        end
      EOS
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      smells = @detector.examine_context(ctx)
      expect(smells.length).to eq(1)
      @warning = smells[0]
    end

    it_should_behave_like 'SmellDetector'
    it_should_behave_like 'common fields set correctly'

    it 'reports the call' do
      expect(@warning.parameters[:name]).to eq('other[@thing]')
    end

    it 'reports the correct lines' do
      expect(@warning.lines).to eq([2, 4])
    end
  end

  context 'with repeated method calls' do
    it 'reports repeated call' do
      src = 'def double_thing() @other.thing + @other.thing end'
      expect(src).to reek_of(:DuplicateMethodCall, name: '@other.thing')
    end

    it 'reports repeated call to lvar' do
      src = 'def double_thing(other) other[@thing] + other[@thing] end'
      expect(src).to reek_of(:DuplicateMethodCall, name: 'other[@thing]')
    end

    it 'reports call parameters' do
      src = 'def double_thing() @other.thing(2,3) + @other.thing(2,3) end'
      expect(src).to reek_of(:DuplicateMethodCall, name: '@other.thing(2, 3)')
    end

    it 'should report nested calls' do
      src = 'def double_thing() @other.thing.foo + @other.thing.foo end'
      expect(src).to reek_of(:DuplicateMethodCall, name: '@other.thing')
      expect(src).to reek_of(:DuplicateMethodCall, name: '@other.thing.foo')
    end

    it 'should ignore calls to new' do
      src = 'def double_thing() @other.new + @other.new end'
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated simple method calls' do
    it 'reports no smell' do
      src = <<-EOS
        def foo
          case bar
          when :baz
            :qux
          else
            bar
          end
        end
      EOS
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated simple method calls with blocks' do
    it 'reports a smell if the blocks are identical' do
      src = <<-EOS
        def foo
          bar { baz }
          bar { baz }
        end
      EOS
      expect(src).to reek_of(:DuplicateMethodCall)
    end

    it 'reports no smell if the blocks are different' do
      src = <<-EOS
        def foo
          bar { baz }
          bar { qux }
        end
      EOS
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated method calls with receivers with blocks' do
    it 'reports a smell if the blocks are identical' do
      src = <<-EOS
        def foo
          bar.qux { baz }
          bar.qux { baz }
        end
      EOS
      expect(src).to reek_of(:DuplicateMethodCall)
    end

    it 'reports a smell if the blocks are different' do
      src = <<-EOS
        def foo
          bar.qux { baz }
          bar.qux { qux }
        end
      EOS
      expect(src).to reek_of(:DuplicateMethodCall)
    end
  end

  context 'with repeated attribute assignment' do
    it 'reports repeated assignment' do
      src = 'def double_thing(thing) @other[thing] = true; @other[thing] = true; end'
      expect(src).to reek_of(:DuplicateMethodCall, name: '@other[thing] = true')
    end
    it 'does not report multi-assignments' do
      src = <<-EOS
        def _parse ctxt
          ctxt.index, result = @ind, @result
          error, ctxt.index = @err, @err_ind
        end
      EOS
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'non-repeated method calls' do
    it 'should not report similar calls' do
      src = 'def equals(other) other.thing == self.thing end'
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end

    it 'should respect call parameters' do
      src = 'def double_thing() @other.thing(3) + @other.thing(2) end'
      expect(src).not_to reek_of(:DuplicateMethodCall)
    end
  end

  context 'allowing up to 3 calls' do
    before :each do
      @config = { DuplicateMethodCall:
                  { Reek::Smells::DuplicateMethodCall::MAX_ALLOWED_CALLS_KEY => 3 } }
    end

    it 'does not report double calls' do
      src = 'def double_thing() @other.thing + @other.thing end'
      with_test_config(@config) do
        expect(src).not_to reek_of(:DuplicateMethodCall)
      end
    end

    it 'does not report triple calls' do
      src = 'def double_thing() @other.thing + @other.thing + @other.thing end'
      with_test_config(@config) do
        expect(src).not_to reek_of(:DuplicateMethodCall)
      end
    end

    it 'reports quadruple calls' do
      src = '
        def double_thing()
          @other.thing + @other.thing + @other.thing + @other.thing
        end
      '
      with_test_config(@config) do
        expect(src).to reek_of(:DuplicateMethodCall, name: '@other.thing', count: 4)
      end
    end
  end

  context 'allowing calls to some methods' do
    before :each do
      @config = { DuplicateMethodCall:
                  { Reek::Smells::DuplicateMethodCall::ALLOW_CALLS_KEY =>
                    ['@some.thing', /puts/] } }
    end

    it 'does not report calls to some methods' do
      src = 'def double_some_thing() @some.thing + @some.thing end'

      with_test_config(@config) do
        expect(src).not_to reek_of(:DuplicateMethodCall)
      end
    end

    it 'reports calls to other methods' do
      src = 'def double_other_thing() @other.thing + @other.thing end'

      with_test_config(@config) do
        expect(src).to reek_of(:DuplicateMethodCall, name: '@other.thing')
      end
    end

    it 'does not report calls to methods specifed with a regular expression' do
      src = 'def double_puts() puts @other.thing; puts @other.thing end'

      with_test_config(@config) do
        expect(src).to reek_of(:DuplicateMethodCall, name: '@other.thing')
      end
    end
  end
end
