require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

def check(desc, src, expected, pending_str = nil)
  it(desc) do
    pending(pending_str) unless pending_str.nil?
    rpt = Report.new
    cchk = MethodChecker.new(rpt, 'Thing')
    cchk.check_source(src)
    rpt.length.should == expected.length
    (0...rpt.length).each do |smell|
      expected[smell].each { |patt| rpt[smell].detailed_report.should match(patt) }
    end
  end
end

describe MethodChecker, "(Long Parameter List)" do
  
  describe 'for methods with few parameters' do
    check 'should report nothing for no parameters', 'def simple; f(3);true; end', []
    check 'should report nothing for 1 parameter', 'def simple(yep) f(3);true end', []
    check 'should report nothing for 2 parameters', 'def simple(yep,zero) f(3);true end', []
    check 'should not count an optional block', 'def simple(alpha, yep, zero, &opt) f(3);true end', []
    check 'should not report inner block with too many parameters',
      'def simple(yep,zero); m[3]; rand(34); f.each { |arga, argb, argc, argd| true}; end', []
    
    describe 'and default values' do
      check 'should report nothing for 1 parameter', 'def simple(zero=nil) f(3);false end', []      
      check 'should report nothing for 2 parameters with 1 default',
        'def simple(yep, zero=nil) f(3);false end', []
      check 'should report nothing for 2 defaulted parameters',
        'def simple(yep=4, zero=nil) f(3);false end', []
    end
  end

  describe 'for methods with too many parameters' do
    check 'should report 4 parameters',
      'def simple(arga, argb, argc, argd) f(3);true end', [[/4 parameters/]]
    check 'should report 8 parameters',
      'def simple(arga, argb, argc, argd,arge, argf, argg, argh) f(3);true end', [[/8 parameters/]]

    describe 'and default values' do
      check 'should report 3 with 1 defaulted',
        'def simple(polly, queue, yep, zero=nil) f(3);false end', [[/4 parameters/]]
      check 'should report with 3 defaulted',
        'def simple(aarg, polly=2, yep=true, zero=nil) f(3);false end', [[/4 parameters/]]
    end
    
    describe 'in a class' do

      before(:each) do
        @rpt = Report.new
        @cchk = MethodChecker.new(@rpt, 'Thing')
      end

      class InnerTest
        def xyzero(arga,argb) f(3);true end
        def abc(argx,yep,zero,argm) f(3);false end
      end

      it 'should only report long param list' do
        @cchk.check_object(InnerTest)
        @rpt.length.should == 1
        @rpt[0].should be_instance_of(LongParameterList)
      end
    end
  end
  
  describe 'yield' do
    check 'should not report yield with no parameters',
      'def simple(arga, argb, &blk) f(3);yield; end', []
    check 'should not report yield with few parameters',
      'def simple(arga, argb, &blk) f(3);yield a,b; end', []
    check 'should report yield with many parameters',
      'def simple(arga, argb, &blk) f(3);yield a,b,a,b; end', [[/yields/, /4/]]
    check 'should not report yield of a long expression',
      'def simple(arga, argb, &blk) f(3);yield(if @dec then argb else 5+3 end); end', []
  end
end

require 'reek/smells/long_parameter_list'
include Reek::Smells

describe LongParameterList, 'when given the class name' do
  
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'classname')
  end

  it 'should report the class name' do
    @cchk.check_source('def simple(arga, argb, argc, argd) f(3);true end')
    @rpt.length.should == 1
    @rpt[0].should be_instance_of(LongParameterList)
    @rpt[0].report.should match(/classname#simple/)
  end
end

describe LongParameterList, '#report' do
  it 'should report the method name and num params' do
    mchk = MethodChecker.new([], 'Class')
    smell = LongParameterList.new(mchk)
    smell.report.should match(/Class/)
  end

end
