require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/smells'
require 'reek/report'

include Reek

describe Report, " when empty" do
  before(:each) do
    @rpt = Report.new
  end

  it 'should have zero length' do
    @rpt.length.should == 0
  end

  it 'should claim to be empty' do
    @rpt.should be_empty
  end
end

describe Report, "to_s" do
  before(:each) do
    rpt = Report.new
    chk = MethodChecker.new(rpt, 'Thing')
    chk.check_source('def simple(a) a[3] end')
    @report = rpt.to_s.split("\n")
  end

  it 'should place each detailed report on a separate line' do
    @report.length.should == 2
  end

  it 'should mention every smell name' do
    @report[0].should match(/[Utility Function]/)
    @report[1].should match(/[Feature Envy]/)
  end
end

describe Report, " as a SortedSet" do
  it 'should only add a smell once' do
    rpt = Report.new
    rpt << UtilityFunction.new(self, 1)
    rpt.length.should == 1
    rpt << UtilityFunction.new(self, 1)
    rpt.length.should == 1
  end
end

describe SortByContext do
  before :each do
    @sorter = SortByContext
  end

  it 'should return 0 for identical smells' do
    smell = LongMethod.new('Class#method')
    @sorter.compare(smell, smell).should == 0
  end

  it 'should return non-0 for different smells' do
    @sorter.compare(LongMethod.new('x'), LargeClass.new('y')).should == -1
  end
end

describe SortBySmell do
  before :each do
    @sorter = SortBySmell
  end
  
  it 'should return 0 for identical smells' do
    @sorter.compare(LongMethod.new('x'), LongMethod.new('x')).should == 0
  end

  it 'should differentiate identical smells with different contexts' do
    @sorter.compare(LongMethod.new('x'), LongMethod.new('y')).should == -1
  end

  it 'should differentiate different smells with identical contexts' do
    @sorter.compare(LongMethod.new('x'), LargeClass.new('x')).should == 1
  end
end
