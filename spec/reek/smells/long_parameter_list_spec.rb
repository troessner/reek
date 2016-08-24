require_relative '../../spec_helper'
require_lib 'reek/smells/long_parameter_list'

RSpec.describe Reek::Smells::LongParameterList do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        def m(a, b, c, d)
        end
      end
    EOS

    expect(src).to reek_of(:LongParameterList,
                           lines:   [2],
                           context: 'Dummy#m',
                           message: 'has 4 parameters',
                           source:  'string',
                           count:   4)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Dummy
        def m1(a, b, c, d)
        end

        def m2(a, b, c, d)
        end
      end
    EOS

    expect(src).to reek_of(:LongParameterList,
                           lines:   [2],
                           context: 'Dummy#m1')
    expect(src).to reek_of(:LongParameterList,
                           lines:   [5],
                           context: 'Dummy#m2')
  end

  it 'should report nothing for 3 parameters' do
    expect('def m(a, b, c); end').not_to reek_of(:LongParameterList)
  end

  it 'should not count an optional block' do
    src = 'def m(a, b, c, &block); end'
    expect(src).not_to reek_of(:LongParameterList)
  end

  it 'should not report inner block with too many parameters' do
    src = <<-EOS
      def m(f)
        f.each { |a, b, c, d| }
      end
    EOS

    expect(src).not_to reek_of(:LongParameterList)
  end

  it 'should report 4 parameters' do
    src = 'def m(a, b, c, d); end'
    expect(src).to reek_of(:LongParameterList, count: 4)
  end

  it 'should report 4 parameters with default parameters' do
    src = 'def m(a = 1, b = 2, c = 3, d = 4); end'
    expect(src).to reek_of(:LongParameterList, count: 4)
  end
end
