require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/module_initialize'

RSpec.describe Reek::SmellDetectors::ModuleInitialize do
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

  it 'reports nothing for a method with a different name' do
    src = <<-EOF
      module Alfa
        def bravo; end
      end
    EOF

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'reports nothing for a method named initialize in a nested class' do
    src = <<-EOF
      module Alfa
        class Bravo
          def initialize; end
        end
      end
    EOF

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'reports nothing for a method named initialize in a nested struct' do
    src = <<-EOF
      module Alfa
        Bravo = Struct.new(:charlie) do
          def initialize; end
        end
      end
    EOF

    expect(src).not_to reek_of(:ModuleInitialize)
  end

  it 'can be disabled via comment' do
    src = <<-EOS
      # :reek:ModuleInitialize
      module Alfa
        def initialize; end
      end
    EOS

    expect(src).not_to reek_of(:ModuleInitialize)
  end
end
