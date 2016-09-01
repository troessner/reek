require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_methods'

RSpec.describe Reek::Smells::TooManyMethods do
  let(:config) do
    { Reek::Smells::TooManyMethods::MAX_ALLOWED_METHODS_KEY => 3 }
  end

  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        def m1; end
        def m2; end
        def m3; end
        def m4; end
      end
    EOS

    expect(src).to reek_of(:TooManyMethods,
                           lines:   [1],
                           context: 'Dummy',
                           message: 'has at least 4 methods',
                           source:  'string',
                           count:   4).with_config(config)
  end

  it 'should not report if we stay below max_methods' do
    src = <<-EOS
      class Dummy
        def m1; end
        def m2; end
        def m3; end
      end
    EOS
    expect(src).not_to reek_of(:TooManyMethods).with_config(config)
  end

  it 'stops at a nested module' do
    src = <<-EOS
      class Dummy
        def m1; end
        def m2; end
        module Hidden
          def m3; end
          def m4; end
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyMethods).with_config(config)
  end
end
