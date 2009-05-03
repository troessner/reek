require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/code_parser'
require 'reek/smells/long_parameter_list'
require 'reek/report'

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
        'def simple(aarg, polly=2, yep=true, zero=nil) f(3);false end'.should reek_only_of(:LongParameterList, /4 parameters/)
      end
    end
    
    describe 'in a class' do
      class InnerTest
        def xyzero(arga,argb) f(3);true end
        def abc(argx,yep,zero,argm) f(3);false end
      end

      it 'should only report long param list' do
        InnerTest.should reek_only_of(:LongParameterList, /abc/)
      end
    end
  end
  
  describe 'yield' do
    it 'should not report yield with no parameters' do
      'def simple(arga, argb, &blk) f(3);yield; end'.should_not reek
    end
    it 'should not report yield with few parameters' do
      'def simple(arga, argb, &blk) f(3);yield a,b; end'.should_not reek
    end
    it 'should report yield with many parameters' do
      'def simple(arga, argb, &blk) f(3);yield arga,argb,arga,argb; end'.should reek_only_of(:LongYieldList, /simple/, /yields/, /4/)
    end
    it 'should not report yield of a long expression' do
      'def simple(arga, argb, &blk) f(3);yield(if @dec then argb else 5+3 end); end'.should_not reek
    end
  end
end
