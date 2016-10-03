require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/too_many_instance_variables'

RSpec.describe Reek::SmellDetectors::TooManyInstanceVariables do
  let(:config) do
    { Reek::SmellDetectors::TooManyInstanceVariables::MAX_ALLOWED_IVARS_KEY => 2 }
  end

  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie = @delta = @echo = 1
        end
      end
    EOS

    expect(src).to reek_of(:TooManyInstanceVariables,
                           lines:   [1],
                           context: 'Alfa',
                           message: 'has at least 3 instance variables',
                           source:  'string',
                           count:   3).with_config(config)
  end

  it 'does not report for non-excessive ivars' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie = @delta = 1
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyInstanceVariables).with_config(config)
  end

  it 'has a configurable maximum' do
    src = <<-EOS
      # :reek:TooManyInstanceVariables: { max_instance_variables: 3 }
      class Alfa
        def bravo
          @charlie = @delta = @echo = 1
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyInstanceVariables).with_config(config)
  end

  it 'counts each ivar only once' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie = @delta = 1
          @charlie = @delta = 1
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyInstanceVariables).with_config(config)
  end

  it 'does not report memoized bravo' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie = @delta = 1
          @echo ||= 1
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyInstanceVariables).with_config(config)
  end

  it 'does not count ivars across inner classes' do
    src = <<-EOS
      class Alfa
        class Bravo
          def charlie
            @delta = @echo = 1
          end
        end

        class Hotel
          def india
            @juliett = 1
          end
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyInstanceVariables).with_config(config)
  end

  it 'does not count ivars across inner modules and classes' do
    src = <<-EOS
      class Alfa
        class Bravo
          def charlie
            @delta = @echo = 1
          end
        end

        module Foxtrot
          def golf
            @hotel = 1
          end
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyInstanceVariables).with_config(config)
  end

  it 'reports excessive ivars across different methods' do
    src = <<-EOS
      class Alfa
        def bravo
          @charlie = @delta = 1
        end

        def golf
          @hotel = 1
        end
      end
    EOS

    expect(src).to reek_of(:TooManyInstanceVariables).with_config(config)
  end
end
