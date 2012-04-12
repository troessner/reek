require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'module_initialize')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek::Smells

describe ModuleInitialize do
  context 'module' do
    context 'with method named initialize' do
      it 'smells' do
        src = <<EOF
        module A
          def initialize; end
        end
EOF
        src.should smell_of(ModuleInitialize)
      end
    end
  end
end
