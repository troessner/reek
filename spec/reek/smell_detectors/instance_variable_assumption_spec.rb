require_relative '../../spec_helper'

require_lib 'reek/smell_detectors/instance_variable_assumption'

RSpec.describe Reek::SmellDetectors::InstanceVariableAssumption do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie
        end
      end
    EOS

    expect(src).to reek_of(:InstanceVariableAssumption,
                           lines:      [1],
                           context:    'Alfa',
                           message:    "assumes too much for instance variable '@charlie'",
                           source:     'string',
                           assumption: '@charlie')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie
        end

        def delta
          @echo
        end
      end

    EOS

    expect(src).
      to reek_of(:InstanceVariableAssumption, lines: [1], assumption: '@charlie').
      and reek_of(:InstanceVariableAssumption, lines: [1], assumption: '@echo')
  end

  it 'does not report an empty class' do
    src = <<-EOS
      class Alfa
      end
    EOS

    expect(src).not_to reek_of(:InstanceVariableAssumption)
  end

  it 'does not report when lazy initializing' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie ||= 1
        end
      end
    EOS

    expect(src).not_to reek_of(:InstanceVariableAssumption)
  end

  it 'reports variable even if others are initialized' do
    src = <<-EOS
      class Alfa
        def initialize
          @bravo = 1
        end

        def charlie
          [@bravo, @delta]
        end
      end
    EOS

    expect(src).to reek_of(:InstanceVariableAssumption, assumption: '@delta')
  end

  it 'reports inner class even if outer class initializes the variable' do
    src = <<-EOS
      class Alfa
        def initialize
          @bravo = 1
        end

        class Charlie
          def delta
            @bravo
          end
        end
      end
    EOS

    expect(src).to reek_of(:InstanceVariableAssumption, context: 'Alfa::Charlie')
  end
end
