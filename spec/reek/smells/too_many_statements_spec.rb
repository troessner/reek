require_relative '../../spec_helper'
require_lib 'reek/smells/too_many_statements'

RSpec.describe Reek::Smells::TooManyStatements do
  let(:config) do
    { Reek::Smells::TooManyStatements::MAX_ALLOWED_STATEMENTS_KEY => 2 }
  end

  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        def m
          a = 1
          b = 2
          c = 3
        end
      end
    EOS

    expect(src).to reek_of(:TooManyStatements,
                           lines:   [2],
                           context: 'Dummy#m',
                           message: 'has approx 3 statements',
                           source:  'string',
                           count:   3).with_config(config)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Dummy
        def m1
          a = 1
          b = 2
          c = 3
        end

        def m2
          x = 1
          y = 2
          z = 3
        end
      end
    EOS

    expect(src).to reek_of(:TooManyStatements,
                           lines:   [2],
                           context: 'Dummy#m1').with_config(config)
    expect(src).to reek_of(:TooManyStatements,
                           lines:   [8],
                           context: 'Dummy#m2').with_config(config)
  end

  it 'does not report short methods' do
    src = <<-EOS
      class Dummy
        def m
          a = 1
          b = 2
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyStatements).with_config(config)
  end

  it 'should not report initialize' do
    src = <<-EOS
      class Dummy
        def initialize
          a = 1
          b = 2
          c = 3
        end
      end
    EOS

    expect(src).not_to reek_of(:TooManyStatements).with_config(config)
  end

  it 'should report long inner block' do
    src = <<-EOS
      def long
        self.each do |x|
          x = 1
          x = 2
          x = 3
        end
      end
    EOS

    expect(src).to reek_of(:TooManyStatements).with_config(config)
  end
end
