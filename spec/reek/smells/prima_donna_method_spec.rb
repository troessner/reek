require_relative '../../spec_helper'
require_lib 'reek/smells/prima_donna_method'

RSpec.describe Reek::Smells::PrimaDonnaMethod do
  it 'reports the right values' do
    src = <<-EOS
      class C
        def m!
        end
      end
    EOS

    expect(src).to reek_of(:PrimaDonnaMethod,
                           lines:   [1],
                           context: 'C',
                           message: 'has prima donna method `m!`',
                           source:  'string',
                           name:    :m!)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class C
        def m1!
        end

        def m2!
        end
      end
    EOS

    expect(src).to reek_of(:PrimaDonnaMethod,
                           lines: [1],
                           name:  :m1!)
    expect(src).to reek_of(:PrimaDonnaMethod,
                           lines: [1],
                           name:  :m2!)
  end

  it 'should report nothing when method and bang counterpart exist' do
    src = <<-EOS
      class C
        def m
        end

        def m!
        end
      end
    EOS

    expect(src).not_to reek_of(:PrimaDonnaMethod)
  end
end
