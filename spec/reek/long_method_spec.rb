require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

describe MethodChecker, "(Long Method)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report short methods' do
    @cchk.check_source('def short(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;end')
    @rpt.should be_empty
  end

  it 'should report long methods' do
    @cchk.check_source('def long(arga) alf = f(1);@bet = 2;@cut = 3;@dit = 4; @emp = 5;@fry = 6;end')
    @rpt.length.should == 1
    @rpt[0].should == LongMethod.new(@cchk)
  end
end

describe MethodChecker, "(Long Block)" do

  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should report long inner block' do
    src = <<EOS
def long(arga)
  f(3)
  37.each do |xyzero|
    xyzero = 1
    xyzero = 2
    xyzero = 3
    xyzero = 4
    xyzero = 5
    xyzero = 6
  end
end
EOS
    @cchk.check_source(src)
    @rpt.length.should == 1
    @rpt[0].report.should match(/block/)
  end
end
