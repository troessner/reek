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

  it "should not report method with successive iterators" do
    source =<<EOS
def bad(fred)
  @fred.each {|item| item.each }
  @jim.each {|ting| ting.each }
end
EOS
    @chk.check_source(source)
    @rpt.should be_empty
  end

  it "should report nested iterators only once per method" do
    source =<<EOS
def bad(fred)
  @fred.each {|item| item.each {|part| @joe.send} }
  @jim.each {|ting| ting.each {|piece| @hal.send} }
end    
EOS
    @chk.check_source(source)
    @rpt.length.should == 1
  end
end

