require File.dirname(__FILE__) + '/../spec_helper.rb'
 
require 'reek/options'

include Reek

describe Options, ' when given no arguments' do
  it "should retain the default sort order" do
    default_order = Options[:sort_order]
    Options.parse ['-e', 'x']
    Options[:sort_order].should == default_order
  end
end

describe Options, ' when --sort_order is specified' do
  before :each do
    @default_order = Options[:sort_order]
  end

  it 'should require an argument' do
    lambda { Options.parse_args(['-s']) }.should raise_error(OptionParser::MissingArgument)
    Options[:sort_order].should == @default_order
  end

  it "should allow sort by smell" do
    Options.parse %w{-s smell -e xx}
    Options[:sort_order].should == Report::SORT_ORDERS[:smell]
  end

  it "should allow sort by context" do
    Options.parse %w{-s context -e xx}
    Options[:sort_order].should == Report::SORT_ORDERS[:context]
  end

  it "should reject illegal sort order" do
    lambda { Options.parse_args(%w{-s tarts}) }.should raise_error(OptionParser::InvalidArgument)
    Options[:sort_order].should == @default_order
  end
end
