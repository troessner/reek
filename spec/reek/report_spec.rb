require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'
require 'reek/smells/smells'
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
    chk = CodeParser.new(rpt)
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
    @long_method = LongMethod.new('x', 30)
    @large_class = LargeClass.new('y', 30)
  end

  it 'should return 0 for identical smells' do
    @sorter.compare(@long_method, @long_method).should == 0
  end

  it 'should return non-0 for different smells' do
    @sorter.compare(@long_method, @large_class).should == -1
  end
end

describe SortBySmell do
  before :each do
    @sorter = SortBySmell
    @long_method = LongMethod.new('x', 30)
    @large_class = LargeClass.new('y', 30)
  end
  
  it 'should return 0 for identical smells' do
    @sorter.compare(@long_method, @long_method).should == 0
  end

  it 'should differentiate identical smells with different contexts' do
    @sorter.compare(LongMethod.new('x', 29), LongMethod.new('y', 29)).should == -1
  end

  it 'should differentiate different smells with identical contexts' do
    @sorter.compare(@long_method, @large_class).should == 1
  end
end
