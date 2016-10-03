require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/repeated_conditional'

RSpec.describe Reek::SmellDetectors::RepeatedConditional do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        attr_accessor :bravo

        def charlie
          puts "Repeat 1!" if bravo
        end

        def delta
          puts "Repeat 2!" if bravo
        end

        def echo
          puts "Repeat 3!" if bravo
        end
      end
    EOS

    expect(src).to reek_of(:RepeatedConditional,
                           lines:   [5, 9, 13],
                           context: 'Alfa',
                           message: "tests 'bravo' at least 3 times",
                           source:  'string',
                           name:    'bravo',
                           count:   3)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alfa
        attr_accessor :bravo

        def charlie
          puts "Repeat 1!" if bravo
          puts "And again!" if bravo
        end

        def delta
          puts "Repeat 2!" if bravo
        end

        def echo
          puts "Repeat 3!" if bravo
        end
      end
    EOS

    expect(src).to reek_of(:RepeatedConditional,
                           lines: [5, 6, 10, 14],
                           count: 4)
  end

  it 'does not report two repeated conditionals' do
    src = <<-EOS
      class Alfa
        attr_accessor :bravo

        def charlie
          puts "Repeat 1!" if bravo
        end

        def delta
          puts "Repeat 2!" if bravo
        end
      end
    EOS

    expect(src).not_to reek_of(:RepeatedConditional)
  end

  it 'reports repeated conditionals regardless of `if` or `case` statements' do
    src = <<-EOS
      class Alfa
        attr_accessor :bravo

        def charlie
          puts "Repeat 1!" if bravo
        end

        def delta
          case bravo
          when 1 then puts "Repeat 2!"
          else 'nothing'
          end
        end

        def echo
          puts "Repeat 3!" if bravo
        end
      end
    EOS

    expect(src).to reek_of(:RepeatedConditional)
  end
end
