require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/long_parameter_list'

include Reek
include Reek::Smells

describe LongParameterList do
  
  describe 'for methods with few parameters' do
    it 'should report nothing for no parameters' do
      'def simple; f(3);true; end'.should_not reek
    end
    it 'should report nothing for 1 parameter' do
      'def simple(yep) f(3);true end'.should_not reek
    end
    it 'should report nothing for 2 parameters' do
      'def simple(yep,zero) f(3);true end'.should_not reek
    end
    it 'should not count an optional block' do
      'def simple(alpha, yep, zero, &opt) f(3);true end'.should_not reek
    end
    it 'should not report inner block with too many parameters' do
      'def simple(yep,zero); m[3]; rand(34); f.each { |arga, argb, argc, argd| true}; end'.should_not reek
    end

    describe 'and default values' do
      it 'should report nothing for 1 parameter' do
        'def simple(zero=nil) f(3);false end'.should_not reek
      end
      it 'should report nothing for 2 parameters with 1 default' do
        'def simple(yep, zero=nil) f(3);false end'.should_not reek
      end
      it 'should report nothing for 2 defaulted parameters' do
        'def simple(yep=4, zero=nil) f(3);false end'.should_not reek
      end
    end
  end

  describe 'for methods with too many parameters' do
    it 'should report 4 parameters' do
      'def simple(arga, argb, argc, argd) f(3);true end'.should reek_only_of(:LongParameterList, /4 parameters/)
    end
    it 'should report 8 parameters' do
      'def simple(arga, argb, argc, argd,arge, argf, argg, argh) f(3);true end'.should reek_only_of(:LongParameterList, /8 parameters/)
    end

    describe 'and default values' do
      it 'should report 3 with 1 defaulted' do
        'def simple(polly, queue, yep, zero=nil) f(3);false end'.should reek_only_of(:LongParameterList, /4 parameters/)
      end
      it 'should report with 3 defaulted' do
        'def simple(aarg, polly=2, yep=:truth, zero=nil) f(3);false end'.should reek_only_of(:LongParameterList, /4 parameters/)
      end
    end
  end
end

require 'spec/reek/smells/smell_detector_shared'

describe LongParameterList do
  before(:each) do
    @source_name = 'smokin'
    @detector = LongParameterList.new(@source_name, {})
    # SMELL: can't use the default config, because that contains an override,
    # which causes the mocked matches?() method to be called twice!!
  end

  it_should_behave_like 'SmellDetector'

  context 'looking at the YAML' do
    before :each do
      @num_parameters = 30
      @ctx = mock('method_context', :null_object => true)
      @ctx.should_receive(:parameters).and_return([0]*@num_parameters)
      @detector.examine_context(@ctx)
      @yaml = @detector.smells_found.to_a[0].to_yaml   # SMELL: too cumbersome!
    end
    it 'reports the source' do
      @yaml.should match(/source:\s*#{@source_name}/)
    end
    it 'reports the class' do
      @yaml.should match(/class:\s*LongParameterList/)
    end
    it 'reports the subclass' do
      @yaml.should match(/subclass:\s*LongParameterList/)
    end
    it 'reports the number of parameters' do
      @yaml.should match(/parameter_count:[\s]*#{@num_parameters}/)
      # SMELL: many tests duplicate the names of the YAML fields
    end
    it 'reports the line number of the method' do
      pending
      @yaml.should match(/lines:\s*- 1/)
    end
  end
end
