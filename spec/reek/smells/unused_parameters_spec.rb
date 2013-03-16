require 'spec_helper'
require 'reek/smells/unused_parameters'
require 'reek/smells/smell_detector_shared'

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

    it 'should report nothing for named parameters prefixed with _' do
      'def simple(_name); end'.should_not smell_of(UnusedParameters)
    end

    it 'should report nothing for unused anonymous splatted parameter' do
      'def simple(*); end'.should_not smell_of(UnusedParameters)
    end

    it 'should report nothing when using super with implicit arguments' do
      'def simple(*args); super; end'.should_not smell_of(UnusedParameters)
    end

    it 'should report something when using super explicitely passing no arguments' do
      'def simple(*args); super(); end'.should smell_of(UnusedParameters)
    end

    it 'should report nothing when using super explicitely passing all arguments' do
      'def simple(*args); super(*args); end'.should_not smell_of(UnusedParameters)
    end

  end
end
