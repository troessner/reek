require_relative '../../spec_helper'
require_lib 'reek/smells/nested_iterators'

RSpec.describe Reek::Smells::NestedIterators do
  it 'reports the right values' do
    src = <<-EOS
      def m(enumerable)
        enumerable.each do |element|
          element.each { |ting| ting.ting }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators,
                           lines:   [3],
                           context: 'm',
                           message: 'contains iterators nested 2 deep',
                           source:  'string',
                           depth:   2)
  end

  it 'does count all occurences' do
    src = <<-EOS
      def m1(enumerable)
        enumerable.each do |element|
          element.each { |ting| ting.ting }
        end
      end

      def m2(enumerable)
        enumerable.each do |element|
          element.each { |ting| ting.ting }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators,
                           lines:   [3],
                           context: 'm1',
                           depth:   2)
    expect(src).to reek_of(:NestedIterators,
                           lines:   [9],
                           context: 'm2',
                           depth:   2)
  end

  it 'reports no smells with no iterators' do
    src = 'def m; end'
    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'reports no smells with one iterator' do
    src = 'def m(enumerable); enumerable.each {}; end'
    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'should not report nested iterators for Object#tap' do
    src = 'def m(*params); [].tap {|list| params.map {|param| list << (param + param)} } end'
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

    expect(src).to reek_of(:NestedIterators, depth: 2)
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

    expect(src).not_to reek_of(:NestedIterators, depth: 2)
    expect(src).to reek_of(:NestedIterators, depth: 3)
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

  it 'reports all lines on which nested iterators occur' do
    source = <<-EOS
      def bad
        @fred.each {|item| item.each {|part| @joe.send} }
        @jim.each {|ting| ting.each {|piece| @hal.send} }
      end
    EOS

    expect(source).to reek_of(:NestedIterators, lines: [2, 3])
  end

  it 'reports separete cases of nested iterators if levels are different' do
    source = <<-EOS
      def bad
        @fred.each {|item| item.each {|part| part.foo} }
        @jim.each {|ting| ting.each {|piece| piece.each {|atom| atom.foo } } }
      end
    EOS

    expect(source).to reek_of(:NestedIterators, lines: [2], depth: 2)
    expect(source).to reek_of(:NestedIterators, lines: [3], depth: 3)
  end

  it 'does not count iterators without block arguments' do
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

  context 'when blocks are specified as lambdas' do
    it 'does not report blocks that are not nested' do
      source = <<-EOS
        def foo
          bar ->(x) { baz x }
        end
      EOS

      expect(source).not_to reek_of(:NestedIterators)
    end

    it 'reports blocks that are nested' do
      source = <<-EOS
        def foo
          bar ->(x) { baz x, ->(y) { quux y } }
        end
      EOS

      expect(source).to reek_of(:NestedIterators)
    end
  end

  it 'reports nested iterators called via safe navigation' do
    source = <<-EOS
      def show_bottles(bars)
        bars&.each do |bar|
          bar&.each do |bottle|
            puts bottle
          end
        end
      end
    EOS

    expect(source).to reek_of(:NestedIterators)
  end

  it 'does not report unnested iterators called via safe navigation' do
    source = <<-EOS
      def show_bottles(bar)
        bar&.each do |bottle|
          puts bottle
        end
      end
    EOS

    expect(source).not_to reek_of(:NestedIterators)
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
      src = <<-EOS
        def bad(fred)
          @fred.ignore_me {|item| item.each {|ting| ting.each {|other| other.other} } }
        end
      EOS

      expect(src).to reek_of(:NestedIterators, depth: 2).with_config(config)
    end

    it 'should report nested iterators outside the ignored iterator' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|item| item.each {|ting| ting.ignore_me {|other| other.other} } }
        end
      EOS

      expect(src).to reek_of(:NestedIterators, depth: 2).with_config(config)
    end

    it 'should report nested iterators with the ignored iterator between them' do
      src = <<-EOS
        def bad(fred)
          @fred.each {|item| item.ignore_me {|ting| ting.ting {|other| other.other} } }
        end
      EOS

      expect(src).to reek_of(:NestedIterators, depth: 2).with_config(config)
    end
  end
end
