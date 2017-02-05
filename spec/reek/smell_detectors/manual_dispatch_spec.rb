require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/too_many_constants'

RSpec.describe Reek::SmellDetectors::ManualDispatch do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        def bravo(charlie)
          true if charlie.respond_to?(:to_a)
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch,
                           lines:   [3],
                           context: 'Alfa#bravo',
                           message: 'manually dispatches method call',
                           source:  'string')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        def bravo(charlie)
          true if charlie.respond_to?(:to_a)
        end

        def delta(echo)
          true if echo.respond_to?(:to_a)
        end
      end
    EOS

    expect(src).
      to reek_of(:ManualDispatch, lines: [3], context: 'Alfa#bravo').
      and reek_of(:ManualDispatch, lines: [7], context: 'Alfa#delta')
  end

  it 'reports manual dispatch smell when using #respond_to? on implicit self' do
    src = <<-EOS
      class Alfa
        def bravo
          charlie if respond_to?(:delta)
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch)
  end

  it 'reports manual dispatch within a conditional' do
    src = <<-EOS
      class Alfa
        def bravo
          charlie.respond_to?(:delta) && charlie.echo
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch)
  end

  it 'reports occurences in a single method as one smell warning' do
    src = <<-EOS
      class Alfa
        def bravo(charlie, delta)
          return true if charlie.respond_to?(:to_a)
          true if delta.respond_to?(:to_a)
        end
      end
    EOS

    expect(src).to reek_of(:ManualDispatch, lines: [3, 4], context: 'Alfa#bravo')
  end
end
