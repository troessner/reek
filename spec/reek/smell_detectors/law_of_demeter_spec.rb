require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/law_of_demeter'

RSpec.describe Reek::SmellDetectors::LawOfDemeter do
  it 'reports the right values' do
    src = <<-EOS
      def alfa(bravo)
        bravo.charlie.delta
      end
    EOS

    expect(src).to reek_of(:LawOfDemeter,
                           lines:   [2],
                           context: 'alfa',
                           message: "violates the law of demeter",
                           source:  'string',
                           name:    :bravo)
  end

  it 'does count all occurences' do
    src = <<-EOS
      def alfa(bravo, charlie)
        bravo.delta.echo
        charlie.foxtrot.gamma
        bravo.delta.echo
      end
    EOS

    expect(src).
      to reek_of(:LawOfDemeter, lines: [2,4], name: 'bravo').
      and reek_of(:LawOfDemeter, lines: [3], name: 'charlie')
  end

  it 'only reports on parameters' do
    src = <<-EOS
      def alfa
        bravo.charlie.delta
      end
    EOS

    expect(src).not_to reek_of(:LawOfDemeter)
  end

  it 'does not report on coincidental identical names' do
    src = <<-EOS
      def alfa(bravo)
        charlie.bravo.delta.echo
      end
    EOS

    expect(src).not_to reek_of(:LawOfDemeter)
  end

  it 'does not report on short regular calls' do
    src = <<-EOS
      def alfa(bravo)
        bravo.charlie(delta)
      end
    EOS

    expect(src).not_to reek_of(:LawOfDemeter)
  end

  it 'does not report on long regular calls' do
    src = <<-EOS
      def alfa(bravo)
        bravo.charlie(delta.echo)
      end
    EOS

    expect(src).not_to reek_of(:LawOfDemeter)
  end
end
