require 'spec_helper'
require 'reek/smells/long_parameter_list'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe LongParameterList do

  context 'for methods with few parameters' do
    it 'should report nothing for no parameters' do
      'def simple; f(3);true; end'.should_not smell_of(LongParameterList)
    end
    it 'should report nothing for 1 parameter' do
      'def simple(yep) f(3);true end'.should_not smell_of(LongParameterList)
    end
    it 'should report nothing for 2 parameters' do
      'def simple(yep,zero) f(3);true end'.should_not smell_of(LongParameterList)
    end
    it 'should not count an optional block' do
      'def simple(alpha, yep, zero, &opt) f(3);true end'.should_not smell_of(LongParameterList)
    end
    it 'should not report inner block with too many parameters' do
      src = 'def simple(yep,zero); m[3]; rand(34); f.each { |arga, argb, argc, argd| true}; end'
      src.should_not smell_of(LongParameterList)
    end

    describe 'and default values' do
      it 'should report nothing for 1 parameter' do
        'def simple(zero=nil) f(3);false end'.should_not smell_of(LongParameterList)
      end
      it 'should report nothing for 2 parameters with 1 default' do
        'def simple(yep, zero=nil) f(3);false end'.should_not smell_of(LongParameterList)
      end
      it 'should report nothing for 2 defaulted parameters' do
        'def simple(yep=4, zero=nil) f(3);false end'.should_not smell_of(LongParameterList)
      end
    end
  end

  describe 'for methods with too many parameters' do
    it 'should report 4 parameters' do
      src = 'def simple(arga, argb, argc, argd) f(3);true end'
      src.should smell_of(LongParameterList, LongParameterList::PARAMETER_COUNT_KEY => 4)
    end
    it 'should report 8 parameters' do
      src = 'def simple(arga, argb, argc, argd,arge, argf, argg, argh) f(3);true end'
      src.should smell_of(LongParameterList, LongParameterList::PARAMETER_COUNT_KEY => 8)
    end

    describe 'and default values' do
      it 'should report 3 with 1 defaulted' do
        src = 'def simple(polly, queue, yep, zero=nil) f(3);false end'
        src.should smell_of(LongParameterList, LongParameterList::PARAMETER_COUNT_KEY => 4)
      end
      it 'should report with 3 defaulted' do
        src = 'def simple(aarg, polly=2, yep=:truth, zero=nil) f(3);false end'
        src.should smell_of(LongParameterList, LongParameterList::PARAMETER_COUNT_KEY => 4)
      end
    end
  end
end

describe LongParameterList do
  before(:each) do
    @source_name = 'smokin'
    @detector = LongParameterList.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'when a smell is reported' do
    before :each do
      src = <<EOS
def badguy(arga, argb, argc, argd)
  f(3)
  true
end
EOS
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the number of parameters' do
      @warning.smell[LongParameterList::PARAMETER_COUNT_KEY].should == 4
    end
    it 'reports the line number of the method' do
      @warning.lines.should == [1]
    end
  end
end
