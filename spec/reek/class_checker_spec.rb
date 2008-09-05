require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/class_checker'

include Reek

describe ClassChecker do

  before(:each) do
    @rpt = []
    @cchk = ClassChecker.new(@rpt)
  end

  it 'should report Long Parameter List' do
    @cchk.check_source('class Inner; def simple(arga, argb, argc, argd) f(3);true end end')
    @rpt.length.should == 1
    @rpt[0].report.should match(/Inner#simple/)
  end

  it 'should report two different methods' do
    src = <<EOEX
class Fred
  def simple(arga, argb, argc, argd) f(3);true end
  def simply(arga, argb, argc, argd) f(3);false end
end
EOEX
    @cchk.check_source(src)
    @rpt.length.should == 2
    @rpt[0].report.should match(/Fred#simple/)
    @rpt[1].report.should match(/Fred#simply/)
  end

  it 'should report many different methods' do
    src = <<EOEX
class Fred
    def textile_bq(tag, atts, cite, content) f(3);end
    def textile_p(tag, atts, cite, content) f(3);end
    def textile_fn_(tag, num, atts, cite, content) f(3);end
    def textile_popup_help(name, windowW, windowH) f(3);end
end
EOEX
    @cchk.check_source(src)
    @rpt.length.should == 3
    @rpt[0].report.should match(/Fred#textile_bq/)
    @rpt[1].report.should match(/Fred#textile_p/)
  end

end
