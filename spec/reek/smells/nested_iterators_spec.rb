require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/nested_iterators'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::NestedIterators do
  context 'with no iterators' do
    it 'reports no smells' do
      src = 'def fred() nothing = true; end'
      expect(src).not_to reek_of(:NestedIterators)
    end
  end

  context 'with one iterator' do
    it 'reports no smells' do
      src = 'def fred() nothing.each {|item| item}; end'
      expect(src).not_to reek_of(:NestedIterators)
    end
  end

  it 'should report nested iterators in a method' do
    src = 'def bad(fred) @fred.each {|item| item.each {|ting| ting.ting} } end'
    expect(src).to reek_of(:NestedIterators)
  end

  it 'should not report method with successive iterators' do
    src = <<-EOS
      def bad(fred)
        @fred.each {|item| item.each }
        @jim.each {|ting| ting.each }
      end
    EOS
    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'should not report method with chained iterators' do
    src = <<-EOS
      def chained
        @sig.keys.sort_by { |xray| xray.to_s }.each { |min| md5 << min.to_s }
      end
    EOS
    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'detects an iterator with an empty block' do
    src = <<-EOS
      def foo
        bar { baz { } }
      end
    EOS
    expect(src).to reek_of(:NestedIterators)
  end

  it 'should report nested iterators only once per method' do
    src = <<-EOS
      def bad(fred)
        @fred.each {|item| item.each {|part| @joe.send} }
        @jim.each {|ting| ting.each {|piece| @hal.send} }
      end
    EOS
    expect(src).to reek_of(:NestedIterators)
  end

  it 'reports nested iterators only once per method even if levels are different' do
    src = <<-EOS
      def bad(fred)
        @fred.each {|item| item.each {|part| part.foo} }
        @jim.each {|ting| ting.each {|piece| piece.each {|atom| atom.foo } } }
      end
    EOS
    expect(src).to reek_of(:NestedIterators)
  end

  it 'reports nesting inside iterator arguments' do
    src = <<-EOS
      def bad(fred, ted)
        fred.foo(
          ted.each {|item|
            item.each {|part|
              part.baz
            }
          }
        ) { |qux| qux.quuz }
      end
    EOS
    expect(src).to reek_of(:NestedIterators, count: 2)
  end

  it 'reports the deepest level of nesting only' do
    src = <<-EOS
      def bad(fred)
        fred.each {|item|
          item.each {|part|
            part.each {|sub| sub.foobar}
          }
        }
      end
    EOS
    expect(src).to reek_of(:NestedIterators, count: 3)
  end

  it 'handles the case where super recieves a block' do
    src = <<-EOS
      def super_call_with_block
        super do |k|
          nothing.each { |thing| item }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  it 'handles the case where super recieves a block and arguments' do
    src = <<-EOS
      def super_call_with_block
        super(foo) do |k|
          nothing.each { |thing| item }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  context 'when the allowed nesting depth is 3' do
    before :each do
      @config = { NestedIterators:
                  { Reek::Smells::NestedIterators::MAX_ALLOWED_NESTING_KEY => 3 } }
    end

    it 'should not report nested iterators 2 levels deep' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|one| one.each {|two| two.two} }
        end
      EOS

      with_test_config(@config) do
        expect(src).not_to reek_of(:NestedIterators)
      end
    end

    it 'should not report nested iterators 3 levels deep' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|one| one.each {|two| two.each {|three| three.three} } }
        end
      EOS

      with_test_config(@config) do
        expect(src).not_to reek_of(:NestedIterators)
      end
    end

    it 'should report nested iterators 4 levels deep' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|one| one.each {|two| two.each {|three| three.each {|four| four.four} } } }
        end
      EOS

      with_test_config(@config) do
        expect(src).to reek_of(:NestedIterators)
      end
    end
  end

  context 'when ignoring iterators' do
    before :each do
      @config = { NestedIterators:
                  { Reek::Smells::NestedIterators::IGNORE_ITERATORS_KEY => ['ignore_me'] } }
    end

    it 'should not report nesting the ignored iterator inside another' do
      src = 'def bad(fred) @fred.each {|item| item.ignore_me {|ting| ting.ting} } end'
      with_test_config(@config) do
        expect(src).not_to reek_of(:NestedIterators)
      end
    end

    it 'should not report nesting inside the ignored iterator' do
      src = 'def bad(fred) @fred.ignore_me {|item| item.each {|ting| ting.ting} } end'
      with_test_config(@config) do
        expect(src).not_to reek_of(:NestedIterators)
      end
    end

    it 'should report nested iterators inside the ignored iterator' do
      src = '
        def bad(fred)
          @fred.ignore_me {|item| item.each {|ting| ting.each {|other| other.other} } }
        end
      '
      with_test_config(@config) do
        expect(src).to reek_of(:NestedIterators, count: 2)
      end
    end

    it 'should report nested iterators outside the ignored iterator' do
      src = '
        def bad(fred)
          @fred.each {|item| item.each {|ting| ting.ignore_me {|other| other.other} } }
        end
      '
      with_test_config(@config) do
        expect(src).to reek_of(:NestedIterators, count: 2)
      end
    end

    it 'should report nested iterators with the ignored iterator between them' do
      src = '
        def bad(fred)
          @fred.each {|item| item.ignore_me {|ting| ting.ting {|other| other.other} } }
        end
      '
      with_test_config(@config) do
        expect(src).to reek_of(:NestedIterators, count: 2)
      end
    end
  end
end

RSpec.describe Reek::Smells::NestedIterators do
  before(:each) do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :NestedIterators, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'when a smell is reported' do
    before :each do
      src = <<-EOS
        def fred()
          nothing.each do |item|
            again.each {|thing| item }
          end
        end
      EOS
      ctx = Reek::Core::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      @warning = @detector.examine_context(ctx)[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports correct values' do
      expect(@warning.parameters[:count]).to eq(2)
      expect(@warning.lines).to eq([3])
    end
  end
end
