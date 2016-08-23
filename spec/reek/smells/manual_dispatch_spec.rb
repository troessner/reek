require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_constants'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::ManualDispatch do
  it 'reports manual dispatch smell when using #respond_to?' do
    src = <<-EOS
      class Dummy
        def call
          fail if unrelated_guard_clause?

          if foo.respond_to?(:bar, true)
            hello
            foo.baz
            foo.bar
          end
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch, message: 'manually dispatches method call', lines: [5])
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
