require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/nil_check'

RSpec.describe Reek::SmellDetectors::NilCheck do
  it 'reports the right values' do
    src = <<-RUBY
      def alfa(bravo)
        bravo.nil?
      end
    RUBY

    expect(src).to reek_of(:NilCheck,
                           lines:   [2],
                           context: 'alfa',
                           message: 'performs a nil-check',
                           source:  'string')
  end

  it 'does count all occurences' do
    src = <<-RUBY
      def alfa(bravo, charlie)
        bravo.nil?
        charlie.nil?
      end
    RUBY

    expect(src).to reek_of(:NilCheck,
                           lines:   [2, 3],
                           context: 'alfa')
  end

  it 'reports nothing when scope includes no nil checks' do
    src = 'def alfa; end'
    expect(src).not_to reek_of(:NilCheck)
  end

  it 'reports when scope uses == nil' do
    src = <<-RUBY
      def alfa(bravo)
        bravo == nil
      end
    RUBY

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses === nil' do
    src = <<-RUBY
      def alfa(bravo)
        bravo === nil
      end
    RUBY

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses nil ==' do
    src = <<-RUBY
      def alfa(bravo)
        nil == bravo
      end
    RUBY

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses a case-clause checking nil' do
    src = <<-RUBY
      def alfa(bravo)
        case bravo
        when nil then puts "Nil"
        end
      end
    RUBY

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports when scope uses &.' do
    src = <<-RUBY
      def alfa(bravo)
        bravo&.charlie
      end
    RUBY

    expect(src).to reek_of(:NilCheck)
  end

  it 'reports all lines when scope uses multiple nilchecks' do
    src = <<-RUBY
      def alfa(bravo)
        bravo.nil?
        @charlie === nil
        delta&.echo
      end
    RUBY

    expect(src).to reek_of(:NilCheck, lines: [2, 3, 4])
  end
end
