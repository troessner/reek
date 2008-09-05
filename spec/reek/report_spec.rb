require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe Report, "to_s" do

  before(:each) do
    rpt = Report.new
    chk = MethodChecker.new(rpt, 'Thing')
    chk.check_source('def simple(arga) arga[3] end')
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

