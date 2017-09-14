require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/prima_donna_method'

RSpec.describe Reek::SmellDetectors::PrimaDonnaMethod do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        def bravo!
        end
      end
    EOS

    expect(src).to reek_of(:PrimaDonnaMethod,
                           lines:   [2],
                           context: 'Alfa',
                           message: "has prima donna method 'bravo!'",
                           source:  'string',
                           name:    'bravo!')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        def bravo!
        end

        def charlie!
        end
      end
    EOS

    expect(src).
      to reek_of(:PrimaDonnaMethod, lines: [2], name: 'bravo!').
      and reek_of(:PrimaDonnaMethod, lines: [5], name: 'charlie!')
  end

  it 'reports nothing when method and bang counterpart exist' do
    src = <<-EOS
      class Alfa
        def bravo
        end

        def bravo!
        end
      end
    EOS

    expect(src).not_to reek_of(:PrimaDonnaMethod)
  end

  it 'does not report methods we excluded via comment' do
    source = <<-EOF
      # :reek:PrimaDonnaMethod: { exclude: [ bravo! ] }
      class Alfa
        def bravo!
        end
      end
    EOF

    expect(source).not_to reek_of(:PrimaDonnaMethod)
  end
end
