require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, " nested iterators" do

  before(:each) do
    @rpt = Report.new
    @chk = MethodChecker.new(@rpt, 'Thing')
  end

  it "should report nested iterators in a method" do
    @chk.check_source('def bad(fred) @fred.each {|item| item.each {|ting| ting.ting} } end')
    @rpt.length.should == 1
  end
end

