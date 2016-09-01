require_relative '../../spec_helper'
require_lib 'reek/smells/module_initialize'

RSpec.describe Reek::Smells::ModuleInitialize do
  it 'reports the right values' do
    src = <<-EOS
      module A
        def initialize; end
      end
    EOS

    expect(src).to reek_of(:ModuleInitialize,
                           lines:   [1],
                           context: 'A',
                           message: 'has initialize method',
                           source:  'string')
  end

  it 'does not report with method named initialize in a nested class' do
    src = <<-EOF
      module A
        class B
          def initialize; end
        end
      end
    EOF

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'does not smell with method named initialize in a nested struct' do
    src = <<-EOF
      module A
        B = Struct.new(:c) do
          def initialize; end
        end
      end
    EOF

    expect(src).not_to reek_of(:ModuleInitialize)
  end
end
