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
  
  it 'should count usages of self' do
    @cchk.check_source('def <=>(other) Options[:sort_order].compare(self, other) end')
    @rpt.should be_empty
  end
  
  it 'should not report overriding methods' do
    class Father
      def thing(ff); @kids = 0; end
    end
    class Son < Father
      def thing(ff); ff; end
    end
    ClassChecker.new(@rpt).check_object(Son)
    @rpt.should be_empty
  end
end
