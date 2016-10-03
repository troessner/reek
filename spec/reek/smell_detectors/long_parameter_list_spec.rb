require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/long_parameter_list'

RSpec.describe Reek::SmellDetectors::LongParameterList do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        def bravo(charlie, delta, echo, foxtrot)
        end
      end
    EOS

    expect(src).to reek_of(:LongParameterList,
                           lines:   [2],
                           context: 'Alfa#bravo',
                           message: 'has 4 parameters',
                           source:  'string',
                           count:   4)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        def bravo(charlie, delta, echo, foxtrot)
        end

        def golf(hotel, india, juliett, kilo)
        end
      end
    EOS

    expect(src).
      to reek_of(:LongParameterList, lines: [2], context: 'Alfa#bravo').
      and reek_of(:LongParameterList, lines: [5], context: 'Alfa#golf')
  end

  it 'reports nothing for 3 parameters' do
    src = 'def alfa(bravo, charlie, delta); end'
    expect(src).not_to reek_of(:LongParameterList)
  end

  it 'does not count an optional block' do
    src = 'def alfa(bravo, charlie, delta, &block); end'
    expect(src).not_to reek_of(:LongParameterList)
  end

  it 'does not report inner block with too many parameters' do
    src = <<-EOS
      def alfa(bravo)
        bravo.each { |charlie, delta, echo, foxtrot| }
      end
    EOS

    expect(src).not_to reek_of(:LongParameterList)
  end

  it 'reports 4 parameters with default parameters' do
    src = 'def alfa(bravo = 1, charlie = 2, delta = 3, echo = 4); end'
    expect(src).to reek_of(:LongParameterList)
  end
end
