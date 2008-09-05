require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, "(Utility Function)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report instance variable reference' do
    @cchk.check_source('def simple(arga) @yellow end')
    @rpt.should be_empty
  end

  it 'should not report vcall' do
    @cchk.check_source('def simple(arga) y end')
    @rpt.should be_empty
  end

  it 'should not report attrset' do
    class Fred
      attr_writer :xyz
    end
    @cchk.check_object(Fred)
    @rpt.should be_empty
  end
end
