require 'spec_helper'
require 'reek/smells/unused_parameters'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe UnusedParameters do
  context 'for methods' do
    it 'reports nothing for no parameters' do
      expect('def simple; true end').not_to smell_of(UnusedParameters)
    end

    it 'reports nothing for used parameter' do
      expect('def simple(sum); sum end').not_to smell_of(UnusedParameters)
    end

    it 'reports for 1 used and 2 unused parameter' do
      src = 'def simple(num,sum,denum); sum end'
      expect(src).to smell_of(UnusedParameters,
                              { name: 'num' },
                              { name: 'denum' })
    end

    it 'reports for 3 used and 1 unused parameter' do
      src = 'def simple(num,sum,denum,quotient); num + denum + sum end'
      expect(src).to smell_of(UnusedParameters,
                              name: 'quotient')
    end

    it 'reports nothing for used splatted parameter' do
      expect('def simple(*sum); sum end').not_to smell_of(UnusedParameters)
    end

    it 'reports nothing for unused anonymous parameter' do
      expect('def simple(_); end').not_to smell_of(UnusedParameters)
    end

    it 'reports nothing for named parameters prefixed with _' do
      expect('def simple(_name); end').not_to smell_of(UnusedParameters)
    end

    it 'reports nothing for unused anonymous splatted parameter' do
      expect('def simple(*); end').not_to smell_of(UnusedParameters)
    end

    it 'reports nothing when using super with implicit arguments' do
      expect('def simple(*args); super; end').not_to smell_of(UnusedParameters)
    end

    it 'reports something when using super explicitely passing no arguments' do
      expect('def simple(*args); super(); end').to smell_of(UnusedParameters)
    end

    it 'reports nothing when using super explicitely passing all arguments' do
      expect('def simple(*args); super(*args); end').not_to smell_of(UnusedParameters)
    end

    it 'reports nothing when using super in a nested context' do
      expect('def simple(*args); call_other("something", super); end').
        not_to smell_of(UnusedParameters)
    end

    it 'reports something when not using a keyword argument with splat' do
      expect('def simple(var, kw: :val, **args); @var, @kw = var, kw; end').
        to smell_of(UnusedParameters)
    end

    it 'reports nothing when using a keyword argument with splat' do
      expect('def simple(var, kw: :val, **args); @var, @kw, @args = var, kw, args; end').
        not_to smell_of(UnusedParameters)
    end
  end
end
