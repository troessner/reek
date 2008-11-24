require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/method_checker'
require 'reek/report'

include Reek

def check(desc, src, expected, pending_str = nil)
  it(desc) do
    pending(pending_str) unless pending_str.nil?
    rpt = Report.new
    cchk = MethodChecker.new(rpt, 'Thing')
    cchk.check_source(src)
    rpt.length.should == expected.length
    (0...rpt.length).each do |smell|
      expected[smell].each { |patt| rpt[smell].detailed_report.should match(patt) }
    end
  end
end

describe MethodChecker, "(Control Couple)" do
  check 'should report a ternary check on a parameter',
    'def simple(arga) arga ? @ivar : 3 end', [[/arga/]]
  check 'should not report a ternary check on an ivar',
    'def simple(arga) @ivar ? arga : 3 end', []
  check 'should not report a ternary check on a lvar',
    'def simple(arga) lvar = 27; lvar ? arga : @ivar end', []
end
