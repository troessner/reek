require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/class_context'
require 'reek/method_checker'
require 'reek/smells/large_class'

include Reek

def check(desc, src, expected, pending_str = nil)
  it(desc) do
    pending(pending_str) unless pending_str.nil?
    rpt = Report.new
    cchk = MethodChecker.new(rpt)
    cchk.check_source(src)
    rpt.length.should == expected.length
    (0...rpt.length).each do |smell|
      expected[smell].each { |patt| rpt[smell].detailed_report.should match(patt) }
    end
  end
end

describe ClassContext do

  before(:each) do
    @rpt = []
    @cchk = MethodChecker.new(@rpt)
  end

  check 'should report Long Parameter List',
    'class Inner; def simple(arga, argb, argc, argd) f(3);true end end', [[/Inner/, /simple/, /4 parameters/]]

    src = <<EOEX
class Fred
  def simple(arga, argb, argc, argd) f(3);true end
  def simply(arga, argb, argc, argd) f(3);false end
end
EOEX
  check 'should report two different methods', src, [[/Fred/, /simple/], [/Fred/, /simply/]]

    src = <<EOEX
class Fred
    def textile_bq(tag, atts, cite, content) f(3);end
    def textile_p(tag, atts, cite, content) f(3);end
    def textile_fn_(tag, num, atts, cite, content) f(3);end
    def textile_popup_help(name, windowW, windowH) f(3);end
end
EOEX
  check 'should report many different methods', src,
    [[/Fred/, /textile_bq/], [/Fred/, /textile_fn_/], [/Fred/, /textile_p/]]
end
