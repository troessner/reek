require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/module_context'
require 'reek/method_checker'
require 'reek/report'

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

describe ModuleContext do
  check 'should report module name for smell in method',
    'module Fred; def simple(x) true; end; end', [[/x/, /simple/, /Fred/]]
end
