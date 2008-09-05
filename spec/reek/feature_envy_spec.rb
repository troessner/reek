require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, "(Feature Envy)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report local method call' do
    @cchk.check_source('def simple(arga) f(17) end')
    @rpt.should be_empty
  end

  it 'should report message chain' do
    @cchk.check_source('def parse(arga) arga.b.c end')
    @rpt.length.should == 2
  end

  it 'should report simple parameter call' do
    @cchk.check_source('def simple(arga) arga[3] end')
    @rpt.length.should == 2
    @rpt[0].should == UtilityFunction.new(@cchk)
    @rpt[1].should == FeatureEnvy.new(@cchk, ':arga')
  end

  it 'should report highest affinity' do
    @cchk.check_source('def simple(arga) slim = ""; s1 = ""; s1.to_s; @m = 34; end')
    @rpt.length.should == 1
    @rpt[0].should == FeatureEnvy.new(@cchk, ':s1')
  end

  it 'should report multiple affinities' do
    @cchk.check_source('def simple(arga) s1 = ""; s1.to_s; s2 = ""; s2.to_s; @m = 34; end')
    @rpt.length.should == 1
    @rpt[0].should == FeatureEnvy.new(@cchk, ':s1 or :s2')
  end

  it 'should not reference global variables' do
    @cchk.check_source('def simple(arga) @s = ""; $s2.to_a; $s2.to_s; end')
    @rpt.length.should == 0
  end

  it 'should not report class methods' do
    @cchk.check_source('def simple() self.class.new.flatten_merge(self) end')
    @rpt.should be_empty
  end
end

describe FeatureEnvy, '#report' do
  it 'should report the envious host' do
    mchk = MethodChecker.new([], 'Class')
    smell = FeatureEnvy.new(mchk, [:lvar, :fred])
    smell.report.should match(/fred/)
    smell.report.should_not match(/:fred/)
  end
end
