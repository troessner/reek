require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/nested_iterators'

RSpec.describe Reek::SmellDetectors::NestedIterators do
  it 'reports the right values' do
    src = <<-EOS
      def alfa(bravo)
        bravo.each do |charlie|
          charlie.each { |delta| delta }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators,
                           lines:   [3],
                           context: 'alfa',
                           message: 'contains iterators nested 2 deep',
                           source:  'string',
                           depth:   2)
  end

  it 'does count all occurences' do
    src = <<-EOS
      def alfa
        bravo.each do |charlie|
          charlie.each { |delta| delta }
        end

        echo.each do |foxtrot|
          foxtrot.each do |golf|
            golf.each { |hotel| hotel }
          end
        end
      end
    EOS

    expect(src).
      to reek_of(:NestedIterators, lines: [3], depth: 2).
      and reek_of(:NestedIterators, lines: [8], depth: 3)
  end

  it 'reports no smells with no iterators' do
    src = 'def alfa; end'
    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'reports no smells with one iterator' do
    src = <<-EOS
      def alfa(bravo)
        bravo.each { |charlie| charlie }
      end
    EOS

    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'does not report nested iterators for Object#tap' do
    src = <<-EOS
      def alfa(bravo)
        bravo.tap do |charlie|
          charlie.each { |delta| delta }
        end
      end
    EOS

    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'does not report method with successive iterators' do
    src = <<-EOS
      def alfa
        @bravo.each   { |charlie| charlie }
        @charlie.each { |delta| delta }
      end
    EOS

    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'does not report method with chained iterators' do
    src = <<-EOS
      def alfa
        bravo.sort_by { |charlie| charlie }.each { |delta| delta }
      end
    EOS

    expect(src).not_to reek_of(:NestedIterators)
  end

  it 'detects an iterator with an empty block' do
    src = <<-EOS
      def alfa
        bravo do |charlie|
          charlie { |delta| }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  it 'reports nesting inside iterator arguments' do
    src = <<-EOS
      def alfa(bravo)
        bravo(
          charlie.each do |delta|
            delta.each { |echo| echo }
          end
        )
      end
    EOS

    expect(src).to reek_of(:NestedIterators, depth: 2)
  end

  it 'reports the deepest level of nesting only' do
    src = <<-EOS
      def alfa(bravo)
        bravo.each do |charlie|
          charlie.each do |delta|
            delta.each { |echo| echo }
          end
        end
      end
    EOS

    expect(src).
      to not_reek_of(:NestedIterators, depth: 2).
      and reek_of(:NestedIterators, depth: 3, lines: [4])
  end

  it 'reports all lines on which nested iterators occur' do
    source = <<-EOS
      def alfa
        @bravo.each { |charlie| charlie.each { |delta| @echo.send } }
        @foxtrot.each { |golf| golf.each { |hotel| @india.send } }
      end
    EOS

    expect(source).to reek_of(:NestedIterators, lines: [2, 3])
  end

  it 'handles the case where super receives a block' do
    src = <<-EOS
      def alfa
        super do |bravo|
          bravo.each { |charlie| charlie }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  it 'handles the case where super receives a block and arguments' do
    src = <<-EOS
      def alfa
        super(delta) do |bravo|
          bravo.each { |charlie| charlie }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  it 'does not count iterators without block arguments' do
    src = <<-EOS
      def alfa
        bravo do
          charlie.each { |delta| delta }
        end
      end
    EOS

    expect(src).not_to reek_of(:NestedIterators)
  end

  context 'when blocks are specified as lambdas' do
    it 'does not report blocks that are not nested' do
      src = <<-EOS
        def alfa
          bravo ->(charlie) { delta }
        end
      EOS

      expect(src).not_to reek_of(:NestedIterators)
    end

    it 'reports blocks that are nested' do
      src = <<-EOS
        def alfa
          bravo ->(charlie) do
            delta ->(echo) { echo }
          end
        end
      EOS

      expect(src).to reek_of(:NestedIterators)
    end
  end

  it 'reports nested iterators called via safe navigation' do
    src = <<-EOS
      def alfa(bravo)
        bravo&.each do |charlie|
          charlie&.each { |delta| delta }
        end
      end
    EOS

    expect(src).to reek_of(:NestedIterators)
  end

  it 'does not report unnested iterators called via safe navigation' do
    src = <<-EOS
      def alfa(bravo)
        bravo&.each { |charlie| charlie }
        delta&.each { |echo| echo }
      end
    EOS

    expect(src).not_to reek_of(:NestedIterators)
  end

  context 'setting the allowed nesting depth to 3' do
    let(:config) do
      { Reek::SmellDetectors::NestedIterators::MAX_ALLOWED_NESTING_KEY => 3 }
    end

    it 'does not report nested iterators 3 levels deep' do
      src = <<-EOS
        def alfa(bravo)
          bravo.each do |charlie|
            charlie.each do |delta|
              delta.each { |echo| echo }
            end
          end
        end
      EOS

      expect(src).not_to reek_of(:NestedIterators).with_config(config)
    end

    it 'reports nested iterators 4 levels deep' do
      src = <<-EOS
        def alfa(bravo)
          bravo.each do |charlie|
            charlie.each do |delta|
              delta.each do |echo|
                echo.each { |foxtrot| foxtrot }
              end
            end
          end
        end
      EOS

      expect(src).to reek_of(:NestedIterators).with_config(config)
    end
  end

  context 'when ignoring iterators' do
    let(:config) do
      { Reek::SmellDetectors::NestedIterators::IGNORE_ITERATORS_KEY => ['ignore_me'] }
    end

    it 'does not report when nesting the ignored iterator inside another' do
      src = <<-EOS
        def alfa(bravo)
          bravo.each do |charlie|
            charlie.ignore_me { |delta| delta }
          end
        end
      EOS

      expect(src).not_to reek_of(:NestedIterators).with_config(config)
    end

    it 'does not report a nested iterator inside the ignored iterator' do
      src = <<-EOS
        def alfa(bravo)
          bravo.ignore_me do |charlie|
            charlie.each { |delta| delta }
          end
        end
      EOS

      expect(src).not_to reek_of(:NestedIterators).with_config(config)
    end

    it 'reports nested iterators inside the ignored iterator' do
      src = <<-EOS
        def alfa(bravo)
          bravo.ignore_me do |charlie|
            charlie.each do |delta|
              delta.each { |echo| echo }
            end
          end
        end
      EOS

      expect(src).to reek_of(:NestedIterators, depth: 2).with_config(config)
    end

    it 'reports nested iterators outside the ignored iterator' do
      src = <<-EOS
        def alfa(bravo)
          bravo.each do |charlie|
            charlie.each do |delta|
              delta.ignore_me { |echo| echo }
            end
          end
        end
      EOS

      expect(src).to reek_of(:NestedIterators, depth: 2).with_config(config)
    end

    it 'reports nested iterators with the ignored iterator between them' do
      src = <<-EOS
        def alfa(bravo)
          bravo.each do |charlie|
            charlie.ignore_me do |delta|
              delta.each { |echo| echo }
            end
          end
        end
      EOS

      expect(src).to reek_of(:NestedIterators, depth: 2).with_config(config)
    end
  end
end
