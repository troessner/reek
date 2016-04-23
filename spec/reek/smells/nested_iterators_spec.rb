require_relative '../../spec_helper'
require_lib 'reek/smells/nested_iterators'
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

  it 'should not report nested iterators for Object#tap' do
    src = 'def do_stuff(*params); [].tap {|list| params.map {|param| list << (param + param)} } end'
    expect(src).not_to reek_of(:NestedIterators)
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
        bar do |bar|
          baz {|baz| }
        end
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

  it 'handles the case where super receives a block' do
    src = <<-EOS
      def super_call_with_block
        super do |k|
          nothing.each { |thing| item }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  it 'handles the case where super receives a block and arguments' do
    src = <<-EOS
      def super_call_with_block
        super(foo) do |k|
          nothing.each { |thing| item }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  describe 'inspect / warnings' do
    let(:detector) { build(:smell_detector, smell_type: :NestedIterators) }

    it 'reports correctly' do
      source = <<-EOS
        def foo
          bar do |bar|
            baz {|baz| }
          end
        end
      EOS
      warnings = detector.inspect(build(:method_context, source: source))
      warning = warnings.first

      expect(warning.smell_type).to eq(Reek::Smells::NestedIterators.smell_type)
      expect(warning.parameters[:name]).to eq('foo')
      expect(warning.lines).to eq([3])
    end

    it 'should report nested iterators only once per method' do
      source = <<-EOS
        def bad(fred)
          @fred.each {|item| item.each {|part| @joe.send} }
          @jim.each {|ting| ting.each {|piece| @hal.send} }
        end
      EOS

      warnings = detector.inspect(build(:method_context, source: source))
      expect(warnings.size).to eq(1)
      warning = warnings.first
      expect(warning.parameters[:name]).to eq('bad')
    end

    it 'reports nested iterators only once per method even if levels are different' do
      source = <<-EOS
        def bad(fred)
          @fred.each {|item| item.each {|part| part.foo} }
          @jim.each {|ting| ting.each {|piece| piece.each {|atom| atom.foo } } }
        end
      EOS
      warnings = detector.inspect(build(:method_context, source: source))
      expect(warnings.size).to eq(1)
      warning = warnings.first

      expect(warning.parameters[:name]).to eq('bad')
      expect(warning.lines).to eq([3])
    end
  end

  describe 'iterators without block arguments' do
    it 'does not count those iterators' do
      source = <<-EOS
        def foo
          before do
            item.each do |part|
              puts part
            end
          end
        end
      EOS
      expect(source).not_to reek_of(:NestedIterators)
    end
  end

  context 'when the allowed nesting depth is 3' do
    let(:config) do
      { Reek::Smells::NestedIterators::MAX_ALLOWED_NESTING_KEY => 3 }
    end

    it 'should not report nested iterators 2 levels deep' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|one| one.each {|two| two.two} }
        end
      EOS

      expect(src).not_to reek_of(:NestedIterators).with_config(config)
    end

    it 'should not report nested iterators 3 levels deep' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|one| one.each {|two| two.each {|three| three.three} } }
        end
      EOS

      expect(src).not_to reek_of(:NestedIterators).with_config(config)
    end

    it 'should report nested iterators 4 levels deep' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|one| one.each {|two| two.each {|three| three.each {|four| four.four} } } }
        end
      EOS

      expect(src).to reek_of(:NestedIterators).with_config(config)
    end
  end

  context 'when ignoring iterators' do
    let(:config) do
      { Reek::Smells::NestedIterators::IGNORE_ITERATORS_KEY => ['ignore_me'] }
    end

    it 'should not report nesting the ignored iterator inside another' do
      src = 'def bad(fred) @fred.each {|item| item.ignore_me {|ting| ting.ting} } end'
      expect(src).not_to reek_of(:NestedIterators).with_config(config)
    end

    it 'should not report nesting inside the ignored iterator' do
      src = 'def bad(fred) @fred.ignore_me {|item| item.each {|ting| ting.ting} } end'
      expect(src).not_to reek_of(:NestedIterators).with_config(config)
    end

    it 'should report nested iterators inside the ignored iterator' do
      src = '
        def bad(fred)
          @fred.ignore_me {|item| item.each {|ting| ting.each {|other| other.other} } }
        end
      '
      expect(src).to reek_of(:NestedIterators, count: 2).with_config(config)
    end

    it 'should report nested iterators outside the ignored iterator' do
      src = '
        def bad(fred)
          @fred.each {|item| item.each {|ting| ting.ignore_me {|other| other.other} } }
        end
      '
      expect(src).to reek_of(:NestedIterators, count: 2).with_config(config)
    end

    it 'should report nested iterators with the ignored iterator between them' do
      src = '
        def bad(fred)
          @fred.each {|item| item.ignore_me {|ting| ting.ting {|other| other.other} } }
        end
      '
      expect(src).to reek_of(:NestedIterators, count: 2).with_config(config)
    end
  end
end

RSpec.describe Reek::Smells::NestedIterators do
  let(:detector) { build(:smell_detector, smell_type: :NestedIterators) }

  it_should_behave_like 'SmellDetector'

  context 'when a smell is reported' do
    let(:warning) do
      src = <<-EOS
        def fred()
          nothing.each do |item|
            again.each {|thing| item }
          end
        end
      EOS
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      detector.inspect(ctx).first
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports correct values' do
      expect(warning.parameters[:count]).to eq(2)
      expect(warning.lines).to eq([3])
    end
  end
end
