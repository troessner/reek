require File.dirname(__FILE__) + '/../spec_helper.rb'
 
require 'reek/options'

include Reek

describe Options, ' when given no arguments' do
  it "should retain the default sort order" do
    default_order = Options[:format]
    Options.parse ['nosuchfile.rb']
    Options[:format].should == default_order
  end
end
