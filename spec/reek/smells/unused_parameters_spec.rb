
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'unused_parameters')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe UnusedParameters do

  context 'for methods' do

    it 'should report nothing for no parameters' do
      'def simple; true end'.should_not smell_of(UnusedParameters)
    end

    it 'should report nothing for used parameter' do
      'def simple(sum); sum end'.should_not smell_of(UnusedParameters)
    end

    it 'should report for 1 used and 2 unused parameter' do
      src = 'def simple(num,sum,denum); sum end'
      src.should smell_of(UnusedParameters,
                          {UnusedParameters::PARAMETER_KEY => 'num'},
                          {UnusedParameters::PARAMETER_KEY => 'denum'})
    end

    it 'should report for 3 used and 1 unused parameter' do
      src = 'def simple(num,sum,denum,quotient); num + denum + sum end'
      src.should smell_of(UnusedParameters,
                          {UnusedParameters::PARAMETER_KEY => 'quotient'})
    end

    it 'should report nothing for used splatted parameter' do
      'def simple(*sum); sum end'.should_not smell_of(UnusedParameters)
    end

    it 'should report nothing for unused anonymous parameter' do
      'def simple(_); end'.should_not smell_of(UnusedParameters)
    end

    it 'should report nothing for unused anonymous splatted parameter' do
      'def simple(*); end'.should_not smell_of(UnusedParameters)
    end

  end
end
