require_relative '../../spec_helper'
require_lib 'reek/smells/prima_donna_method'

RSpec.describe Reek::Smells::PrimaDonnaMethod do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        def bravo!
        end
      end
    EOS

    expect(src).to reek_of(:PrimaDonnaMethod,
                           lines:   [1],
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

    expect(src).to reek_of(:PrimaDonnaMethod,
                           lines: [1],
                           name:  'bravo!')
    expect(src).to reek_of(:PrimaDonnaMethod,
                           lines: [1],
                           name:  'charlie!')
  end

  it 'should report nothing when method and bang counterpart exist' do
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
end
