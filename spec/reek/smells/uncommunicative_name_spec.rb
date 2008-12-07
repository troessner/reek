require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'spec/reek/code_checks'

include CodeChecks

describe CodeParser, "uncommunicative method name" do
  check 'should not report one-word method name', 'def help(fred) basics(17) end', []
  check 'should report one-letter method name', 'def x(fred) basics(17) end', [[/x/, /method name/]]
  check 'should report name of the form "x2"', 'def x2(fred) basics(17) end', [[/x2/, /method name/]]
end

describe CodeParser, "uncommunicative field name" do
  check 'should not report one-word field name', 'def help(fred) @simple end', []
  check 'should report one-letter fieldname', 'def simple(fred) @x end', [[/@x/, /field name/]]
  check 'should report name of the form "x2"', 'def simple(fred) @x2 end', [[/@x2/, /field name/]]
  check 'should report one-letter fieldname in assignment', 'def simple(fred) @x = fred end', [[/@x/, /field name/]]
end

#describe CodeParser, "uncommunicative class variable name" do
#  check 'should not report one-word name', 'def help(fred) @@vari - @simple end', []
#  check 'should report one-letter name', 'def simple(fred) @@x end', [[/@@x/, /field name/]]
#  check 'should report name of the form "x2"', 'def simple(fred) @@x2 end', [[/@@x2/, /field name/]]
#  check 'should report one-letter name in assignment', 'def simple(fred) @@x = fred end', [[/@@x/, /field name/]]
#end

describe CodeParser, "uncommunicative local variable name" do
  check 'should not report one-word variable name', 'def help(fred) simple = jim(45) end', []
  check 'should report one-letter variable name', 'def simple(fred) x = jim(45) end', [[/x/, /local variable name/]]
  check 'should report name of the form "x2"', 'def simple(fred) x2 = jim(45) end', [[/x2/, /local variable name/]]
  check 'should report variable name only once', 'def simple(fred) x = jim(45); x = y end', [[]]
end

describe CodeParser, "uncommunicative parameter name" do
  check 'should not recognise *', 'def help(xray, *) basics(17) end', []
  check "should report parameter's name", 'def help(x) basics(17) end', [[/x/, /parameter name/]]
  check 'should report name of the form "x2"', 'def help(x2) basics(17) end', [[/x2/, /parameter name/]]
end

describe CodeParser, "uncommunicative block parameter name" do
  check "should report parameter's name", 'def help() @stuff.each {|x|} end', [[/x/, /block/, /parameter name/]]
  
  src = <<EOS
def bad
  unless @mod then
    @sig.each { |x| x.to_s }
  end
end
EOS
  check "should report method name via if context", src, [[/x/, /block/, /bad/]]
end

describe CodeParser, "several uncommunicative names" do

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
require 'reek/smells/uncommunicative_name'
include Reek::Smells

describe UncommunicativeName, '#examine' do
  before :each do
    @report = Report.new
  end
  
  it 'should return true when reporting a smell' do
    mc = MethodContext.new(StopContext.new, [:defn, :x, nil])
    UncommunicativeName.examine(mc, @report).should == true
  end
  
  it 'should return false when not reporting a smell' do
    mc = MethodContext.new(StopContext.new, [:defn, :not_bad, nil])
    UncommunicativeName.examine(mc, @report).should == false
  end
end
