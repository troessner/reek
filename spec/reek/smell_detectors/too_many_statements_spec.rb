require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/too_many_statements'

RSpec.describe Reek::SmellDetectors::TooManyStatements do
  let(:config) do
    { Reek::SmellDetectors::TooManyStatements::MAX_ALLOWED_STATEMENTS_KEY => 2 }
  end

  it 'reports the right values' do
    src = <<-RUBY
      class Alfa
        def bravo
          charlie = 1
          delta   = 2
          echo    = 3
        end
      end
    RUBY

    expect(src).to reek_of(:TooManyStatements,
                           lines:   [2],
                           context: 'Alfa#bravo',
                           message: 'has approx 3 statements',
                           source:  'string',
                           count:   3).with_config(config)
  end

  it 'does count all occurences' do
    src = <<-RUBY
      class Alfa
        def bravo
          charlie = 1
          delta   = 2
          echo    = 3
        end

        def foxtrot
          golf  = 1
          hotel = 2
          india = 3
        end
      end
    RUBY

    expect(src).
      to reek_of(:TooManyStatements, lines: [2], context: 'Alfa#bravo').with_config(config).
      and reek_of(:TooManyStatements, lines: [8], context: 'Alfa#foxtrot').with_config(config)
  end

  it 'does not report short methods' do
    src = <<-RUBY
      class Alfa
        def bravo
          charlie = 1
          delta   = 2
        end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyStatements).with_config(config)
  end

  it 'does not report initialize' do
    src = <<-RUBY
      class Alfa
        def initialize
          charlie = 1
          delta   = 2
          echo    = 3
        end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyStatements).with_config(config)
  end

  it 'reports long inner block' do
    src = <<-RUBY
      def long
        self.each do |x|
          charlie = 1
          delta   = 2
          echo    = 3
        end
      end
    RUBY

    expect(src).to reek_of(:TooManyStatements).with_config(config)
  end
end
