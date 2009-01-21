require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'
require 'reek/smells/smells'
require 'reek/report'
require 'reek'

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
    rpt = Analyser.new('def simple(a) a[3] end').analyse
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
    rpt << SmellWarning.new('ha', self, self)
    rpt.length.should == 1
    rpt << SmellWarning.new('ha', self, self)
    rpt.length.should == 1
  end
end

describe 'sorting' do
  before :each do
    @long_method = SmellWarning.new('Long Method', 'x', 30)
    @large_class = SmellWarning.new('Large Class', 'y', 30)
  end

  describe SortByContext do
    before :each do
      @sorter = SortByContext
    end

    it 'should return 0 for identical smells' do
      @sorter.compare(@long_method, @long_method).should == 0
    end

    it 'should return non-0 for different smells' do
      @sorter.compare(@long_method, @large_class).should_not == 0
    end
  end

  describe SortBySmell do
    before :each do
      @sorter = SortBySmell
    end

    it 'should return 0 for identical smells' do
      @sorter.compare(@long_method, @long_method).should == 0
    end

    it 'should differentiate identical smells with different contexts' do
      @sorter.compare(SmellWarning.new('Long Method', 'x', 29), SmellWarning.new('Long Method', 'y', 29)).should == -1
    end

    it 'should differentiate different smells with identical contexts' do
      @sorter.compare(@long_method, @large_class).should == 1
    end
  end
end
