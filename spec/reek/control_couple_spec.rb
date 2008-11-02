require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, "(Control Couple)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should report a ternary check on a parameter' do
    @cchk.check_source('def simple(arga) arga ? @ivar : 3 end')
    @rpt.length.should == 1
    ControlCouple.should === @rpt[0]
    @rpt[0].to_s.should match(/arga/)
  end

  it 'should not report a ternary check on an ivar' do
    @cchk.check_source('def simple(arga) @ivar ? arga : 3 end')
    @rpt.should be_empty
  end

  it 'should not report a ternary check on a lvar' do
    @cchk.check_source('def simple(arga) lvar = 27; lvar ? arga : @ivar end')
    @rpt.should be_empty
  end
end
