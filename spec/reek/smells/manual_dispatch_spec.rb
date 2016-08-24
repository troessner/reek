require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_constants'

RSpec.describe Reek::Smells::ManualDispatch do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        def m(a)
          true if a.respond_to?(:to_a)
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch,
                           lines:   [3],
                           context: 'Dummy#m',
                           message: 'manually dispatches method call',
                           source:  'string')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Dummy
        def m1(a)
          true if a.respond_to?(:to_a)
        end

        def m2(a)
          true if a.respond_to?(:to_a)
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch,
                           lines:   [3],
                           context: 'Dummy#m1')
    expect(src).to reek_of(:ManualDispatch,
                           lines:   [7],
                           context: 'Dummy#m2')
  end

  it 'reports manual dispatch smell when using #respond_to? on implicit self' do
    src = <<-EOS
      class Dummy
        def call
          bar if respond_to?(:bar)
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch)
  end

  it 'reports manual dispatch within a conditional' do
    src = <<-EOS
      class Dummy
        def call
          foo.respond_to?(:bar) && foo.bar
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch)
  end
end
