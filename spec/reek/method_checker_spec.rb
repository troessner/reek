require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, "(Long Parameter List)" do
  
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  describe 'with no method definitions' do
    it 'should report no problems for empty source code' do
      @cchk.check_source('')
      @rpt.should be_empty
    end

    it 'should report no problems for empty class' do
      @cchk.check_source('class Fred; end')
      @rpt.should be_empty
    end
  end
  
  describe 'for methods with few parameters' do
    it 'should report nothing for no parameters' do
      @cchk.check_source('def simple; f(3);true; end')
      @rpt.should be_empty
    end

    it 'should report nothing for 1 parameter' do
      @cchk.check_source('def simple(yep) f(3);true end')
      @rpt.should be_empty
    end

    it 'should report nothing for 2 parameters' do
      @cchk.check_source('def simple(yep,zero) f(3);true end')
      @rpt.should be_empty
    end

    it 'should not count an optional block' do
      @cchk.check_source('def simple(alpha, yep, zero, &opt) f(3);true end')
      @rpt.should be_empty
    end

    it 'should not report inner block with too many parameters' do
      @cchk.check_source('def simple(yep,zero); m[3]; rand(34); f.each { |arga, argb, argc, argd| true}; end')
      @rpt.should be_empty
    end
    
    describe 'and default values' do
      it 'should report nothing for 1 parameter' do
        @cchk.check_source('def simple(zero=nil) f(3);false end')
        @rpt.should be_empty
      end
      
      it 'should report nothing for 2 parameters with 1 default' do
        @cchk.check_source('def simple(yep, zero=nil) f(3);false end')
        @rpt.should be_empty
      end
      
      it 'should report nothing for 2 defaulted parameters' do
        @cchk.check_source('def simple(yep=4, zero=nil) f(3);false end')
        @rpt.should be_empty
      end
    end
  end

  describe 'for methods with too many parameters' do
    it 'should report 4 parameters' do
      @cchk.check_source('def simple(arga, argb, argc, argd) f(3);true end')
      @rpt.length.should == 1
      @rpt[0].should == LongParameterList.new(@cchk)
    end
    
    it 'should report 8 parameters' do
      @cchk.check_source('def simple(arga, argb, argc, argd,arge, argf, argg, argh) f(3);true end')
      @rpt.length.should == 1
      @rpt[0].should == LongParameterList.new(@cchk)
    end

    describe 'and default values' do
      it 'should report 3 with 1 defaulted' do
        @cchk.check_source('def simple(polly, queue, yep, zero=nil) f(3);false end')
        @rpt.length.should == 1
        @rpt[0].should == LongParameterList.new(@cchk)
      end

      it 'should report with 3 defaulted' do
        @cchk.check_source('def simple(aarg, polly=2, yep=true, zero=nil) f(3);false end')
        @rpt.length.should == 1
        @rpt[0].should == LongParameterList.new(@cchk)
      end
    end
    
    describe 'in a class' do
      class InnerTest
        def xyzero(arga,argb) f(3);true end
        def abc(argx,yep,zero,argm) f(3);false end
      end

      it 'should only report long param list' do
        @cchk.check_object(InnerTest)
        @rpt.length.should == 1
        @rpt[0].should == LongParameterList.new(@cchk)
      end
    end
  end
  
  describe 'yield' do
    it 'should not report yield with few parameters' do
      @cchk.check_source('def simple(arga, argb, &blk) f(3);yield a,b; end')
      @rpt.should be_empty
    end

    it 'should report yield with many parameters' do
      @cchk.check_source('def simple(arga, argb, &blk) f(3);yield a,b,a,b; end')
      @rpt.length.should == 1
      @rpt[0].should == LongYieldList.new(@cchk)
    end

  end

end

describe MethodChecker, 'when given the class name' do
  
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'classname')
  end

  it 'should report the class name' do
    @cchk.check_source('def simple(arga, argb, argc, argd) f(3);true end')
    @rpt.length.should == 1
    @rpt[0].should == LongParameterList.new(@cchk)
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

describe MethodChecker, "(Long Method)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report short methods' do
    @cchk.check_source('def short(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;end')
    @rpt.should be_empty
  end

  it 'should report long methods' do
    @cchk.check_source('def long(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end')
    @rpt.length.should == 1
    @rpt[0].should == LongMethod.new(@cchk)
  end

  it 'should report long inner block' do
    src = <<EOS
def long(arga)
  f(3)
  37.each do |xyzero|
    xyzero = 1
    xyzero = 2
    xyzero = 3
    xyzero = 4
    xyzero = 5
    xyzero = 6
  end
end
EOS
    @cchk.check_source(src)
    @rpt.length.should == 1
    @rpt[0].report.should match(/block/)
  end
end

describe MethodChecker, 'when given a C extension' do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should ignore :cfunc' do
    @cchk.check_object(Enumerable)
  end
end

