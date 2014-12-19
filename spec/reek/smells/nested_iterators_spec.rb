require 'spec_helper'
require 'reek/smells/nested_iterators'
require 'reek/smells/smell_detector_shared'

include Reek::Smells

describe NestedIterators do
  context 'with no iterators' do
    it 'reports no smells' do
      src = 'def fred() nothing = true; end'
      expect(src).not_to smell_of(NestedIterators)
    end
  end

  context 'with one iterator' do
    it 'reports no smells' do
      src = 'def fred() nothing.each {|item| item}; end'
      expect(src).not_to smell_of(NestedIterators)
    end
  end

  it 'should report nested iterators in a method' do
    src = 'def bad(fred) @fred.each {|item| item.each {|ting| ting.ting} } end'
    expect(src).to smell_of(NestedIterators)
  end

  it 'should not report method with successive iterators' do
    src = <<EOS
def bad(fred)
  @fred.each {|item| item.each }
  @jim.each {|ting| ting.each }
end
EOS
    expect(src).not_to smell_of(NestedIterators)
  end

  it 'should not report method with chained iterators' do
    src = <<EOS
def chained
  @sig.keys.sort_by { |xray| xray.to_s }.each { |min| md5 << min.to_s }
end
EOS
    expect(src).not_to smell_of(NestedIterators)
  end

  it 'detects an iterator with an empty block' do
    src = <<-EOS
      def foo
        bar { baz { } }
      end
    EOS
    expect(src).to smell_of(NestedIterators, {})
  end

  it 'should report nested iterators only once per method' do
    src = <<EOS
def bad(fred)
  @fred.each {|item| item.each {|part| @joe.send} }
  @jim.each {|ting| ting.each {|piece| @hal.send} }
end
EOS
    expect(src).to smell_of(NestedIterators, {})
  end

  it 'reports nested iterators only once per method even if levels are different' do
    src = <<-EOS
      def bad(fred)
        @fred.each {|item| item.each {|part| part.foo} }
        @jim.each {|ting| ting.each {|piece| piece.each {|atom| atom.foo } } }
      end
    EOS
    expect(src).to smell_of(NestedIterators, {})
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
    expect(src).to smell_of(NestedIterators, count: 2)
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
    expect(src).to smell_of(NestedIterators, count: 3)
  end

  context 'when the allowed nesting depth is 3' do
    before :each do
      @config = { NestedIterators::MAX_ALLOWED_NESTING_KEY => 3 }
    end

    it 'should not report nested iterators 2 levels deep' do
      src = <<EOS
def bad(fred)
  @fred.each {|one| one.each {|two| two.two} }
end
EOS
      expect(src).not_to smell_of(NestedIterators).with_config(@config)
    end

    it 'should not report nested iterators 3 levels deep' do
      src = <<EOS
def bad(fred)
  @fred.each {|one| one.each {|two| two.each {|three| three.three} } }
end
EOS
      expect(src).not_to smell_of(NestedIterators).with_config(@config)
    end

    it 'should report nested iterators 4 levels deep' do
      src = <<EOS
def bad(fred)
  @fred.each {|one| one.each {|two| two.each {|three| three.each {|four| four.four} } } }
end
EOS
      expect(src).to smell_of(NestedIterators).with_config(@config)
    end
  end

  context 'when ignoring iterators' do
    before :each do
      @config = { NestedIterators::IGNORE_ITERATORS_KEY => ['ignore_me'] }
    end

    it 'should not report nesting the ignored iterator inside another' do
      src = 'def bad(fred) @fred.each {|item| item.ignore_me {|ting| ting.ting} } end'
      expect(src).not_to smell_of(NestedIterators).with_config(@config)
    end

    it 'should not report nesting inside the ignored iterator' do
      src = 'def bad(fred) @fred.ignore_me {|item| item.each {|ting| ting.ting} } end'
      expect(src).not_to smell_of(NestedIterators).with_config(@config)
    end

    it 'should report nested iterators inside the ignored iterator' do
      src = '
        def bad(fred)
          @fred.ignore_me {|item| item.each {|ting| ting.each {|other| other.other} } }
        end
      '
      expect(src).to smell_of(NestedIterators, count: 2).with_config(@config)
    end

    it 'should report nested iterators outside the ignored iterator' do
      src = '
        def bad(fred)
          @fred.each {|item| item.each {|ting| ting.ignore_me {|other| other.other} } }
        end
      '
      expect(src).to smell_of(NestedIterators, count: 2).with_config(@config)
    end

    it 'should report nested iterators with the ignored iterator between them' do
      src = '
        def bad(fred)
          @fred.each {|item| item.ignore_me {|ting| ting.ting {|other| other.other} } }
        end
      '
      expect(src).to smell_of(NestedIterators, count: 2).with_config(@config)
    end
  end
end

describe NestedIterators do
  before(:each) do
    @source_name = 'cuckoo'
    @detector = NestedIterators.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'when a smell is reported' do
    before :each do
      src = <<EOS
def fred()
  nothing.each do |item|
    again.each {|thing| item }
  end
end
EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @warning = @detector.examine_context(ctx)[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports correct values' do
      expect(@warning.parameters[:count]).to eq(2)
      expect(@warning.lines).to eq([3])
    end
  end
end
