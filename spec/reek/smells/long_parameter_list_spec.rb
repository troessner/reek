require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'spec/reek/code_checks'

include CodeChecks

require 'reek/code_parser'
require 'reek/smells/long_parameter_list'
require 'reek/report'

include Reek
include Reek::Smells

describe CodeParser, "(Long Parameter List)" do
  
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
        @cchk = CodeParser.new(@rpt)
      end

      class InnerTest
        def xyzero(arga,argb) f(3);true end
        def abc(argx,yep,zero,argm) f(3);false end
      end

      it 'should only report long param list' do
        @cchk.check_object(InnerTest)
        @rpt.length.should == 1
        @rpt[0].should be_instance_of(LongParameterListReport)
      end
    end
  end
  
  describe 'yield' do
    check 'should not report yield with no parameters',
      'def simple(arga, argb, &blk) f(3);yield; end', []
    check 'should not report yield with few parameters',
      'def simple(arga, argb, &blk) f(3);yield a,b; end', []
    check 'should report yield with many parameters',
      'def simple(arga, argb, &blk) f(3);yield a,b,a,b; end', [[/simple/, /yields/, /4/]]
    check 'should not report yield of a long expression',
      'def simple(arga, argb, &blk) f(3);yield(if @dec then argb else 5+3 end); end', []
  end
end
