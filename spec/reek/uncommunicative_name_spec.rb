require File.dirname(__FILE__) + '/../spec_helper.rb'

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

describe MethodChecker, "uncommunicative method name" do
  check 'should not report one-word method name', 'def help(fred) basics(17) end', []
  check 'should report one-letter method name', 'def x(fred) basics(17) end', [[/x/, /method name/]]
  check 'should report name of the form "x2"', 'def x2(fred) basics(17) end', [[/x2/, /method name/]]
end

describe MethodChecker, "uncommunicative field name" do
  check 'should not report one-word field name', 'def help(fred) @simple end', []
  check 'should report one-letter fieldname', 'def simple(fred) @x end', [[/@x/, /field name/]]
  check 'should report name of the form "x2"', 'def simple(fred) @x2 end', [[/@x2/, /field name/]]
  check 'should report one-letter fieldname in assignment', 'def simple(fred) @x = fred end', [[/@x/, /field name/]]
end

describe MethodChecker, "uncommunicative local variable name" do
  check 'should not report one-word variable name', 'def help(fred) simple = jim(45) end', []
  check 'should report one-letter variable name', 'def simple(fred) x = jim(45) end', [[/x/, /local variable name/]]
  check 'should report name of the form "x2"', 'def simple(fred) x2 = jim(45) end', [[/x2/, /local variable name/]]
  check 'should report variable name only once', 'def simple(fred) x = jim(45); x = y end', [[]]
end

describe MethodChecker, "uncommunicative parameter name" do
  check 'should recognise short parameter name', 'def help(x) basics(17) end', [[]]
  check 'should not recognise *', 'def help(xray, *) basics(17) end', []
  check "should report parameter's name", 'def help(x) basics(17) end', [[/x/, /parameter name/]]
  check 'should report name of the form "x2"', 'def help(x2) basics(17) end', [[/x2/, /parameter name/]]
end

describe MethodChecker, "several uncommunicative names" do

  check 'should report all bad names', 'def y(x) @z = x end', [[/'@z'/], [/'y'/], [/'x'/]]

  source =<<EOS
def bad(fred)
  @fred.each {|x| 4 - x }
  @jim.each {|y| y - 4 }
end
EOS
  check 'should report all bad block parameters', source, [[/'x'/], [/'y'/]], 'bug'
end

require 'ostruct'

describe UncommunicativeName, '#examine' do
  
  before :each do
    @mc = OpenStruct.new
    @mc.parameters = []
    @mc.local_variables = []
    @mc.instance_variables = []
  end

  it 'should return true when reporting a smell' do
    @mc.name = 'x'
    UncommunicativeName.examine(@mc, []).should == true
  end
  
  it 'should return false when not reporting a smell' do
    @mc.name = 'not_bad'
    UncommunicativeName.examine(@mc, []).should == false
  end
end
