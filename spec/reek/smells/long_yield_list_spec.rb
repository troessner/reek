require_relative '../../spec_helper'
require_lib 'reek/smells/long_yield_list'

RSpec.describe Reek::Smells::LongYieldList do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        def m(a, b, c, d)
          yield a, b, c, d
        end
      end
    EOS

    expect(src).to reek_of(:LongYieldList,
                           lines:   [3],
                           context: 'Dummy#m',
                           message: 'yields 4 parameters',
                           source:  'string',
                           count:   4)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Dummy
        def m1(a, b, c, d)
          yield a, b, c, d
        end

        def m2(a, b, c, d)
          yield a, b, c, d
        end
      end
    EOS

    expect(src).to reek_of(:LongYieldList,
                           lines:   [3],
                           context: 'Dummy#m1')
    expect(src).to reek_of(:LongYieldList,
                           lines:   [7],
                           context: 'Dummy#m2')
  end

  it 'should not report yield with no parameters' do
    src = <<-EOS
      def m
        yield
      end
    EOS

    expect(src).not_to reek_of(:LongYieldList)
  end

  it 'should not report yield with 3 parameters' do
    src = <<-EOS
      def m(a, b, c)
        yield a, b, c
      end
    EOS

    expect(src).not_to reek_of(:LongYieldList)
  end

  it 'should report yield with 4 parameters' do
    src = <<-EOS
      def m(a, b, c, d)
        yield a, b, c, d
      end
    EOS

    expect(src).to reek_of(:LongYieldList)
  end
end
