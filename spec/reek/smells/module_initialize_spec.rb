require_relative '../../spec_helper'
require_lib 'reek/smells/module_initialize'

RSpec.describe Reek::Smells::ModuleInitialize do
  it 'reports the right values' do
    src = <<-EOS
      module Alfa
        def initialize; end
      end
    EOS

    expect(src).to reek_of(:ModuleInitialize,
                           lines:   [1],
                           context: 'Alfa',
                           message: 'has initialize method',
                           source:  'string')
  end

  it 'does not report with method named initialize in a nested class' do
    src = <<-EOF
      module Alfa
        class Bravo
          def initialize; end
        end
      end
    EOF

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'does not smell with method named initialize in a nested struct' do
    src = <<-EOF
      module Alfa
        Bravo = Struct.new(:charlie) do
          def initialize; end
        end
      end
    EOF

    expect(src).not_to reek_of(:ModuleInitialize)
  end
end
