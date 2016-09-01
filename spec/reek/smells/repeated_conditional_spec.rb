require_relative '../../spec_helper'
require_lib 'reek/smells/repeated_conditional'

RSpec.describe Reek::Smells::RepeatedConditional do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        attr_accessor :switch

        def repeat_1
          puts "Repeat 1!" if switch
        end

        def repeat_2
          puts "Repeat 2!" if switch
        end

        def repeat_3
          puts "Repeat 3!" if switch
        end
      end
    EOS

    expect(src).to reek_of(:RepeatedConditional,
                           lines:   [5, 9, 13],
                           context: 'Dummy',
                           message: 'tests switch at least 3 times',
                           source:  'string',
                           name:    'switch',
                           count:   3)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Dummy
        attr_accessor :switch

        def repeat_1
          puts "Repeat 1!" if switch
          puts "And again!" if switch
        end

        def repeat_2
          puts "Repeat 2!" if switch
        end

        def repeat_3
          puts "Repeat 3!" if switch
        end
      end
    EOS

    expect(src).to reek_of(:RepeatedConditional, lines: [5, 6, 10, 14], count: 4)
  end

  it 'does not report two repeated conditionals' do
    src = <<-EOS
      class Dummy
        attr_accessor :switch

        def repeat_1
          puts "Repeat 1!" if switch
        end

        def repeat_2
          puts "Repeat 2!" if switch
        end
      end
    EOS

    expect(src).not_to reek_of(:RepeatedConditional)
  end

  it 'reports repeated conditionals regardless of `if` or `case` statements' do
    src = <<-EOS
      class Dummy
        attr_accessor :switch

        def repeat_1
          puts "Repeat 1!" if switch
        end

        def repeat_2
          case switch
          when 1 then puts "Repeat 2!"
          else 'nothing'
          end
        end

        def repeat_3
          puts "Repeat 3!" if switch
        end
      end
    EOS

    expect(src).to reek_of(:RepeatedConditional)
  end
end
