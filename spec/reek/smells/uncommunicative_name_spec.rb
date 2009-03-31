require File.dirname(__FILE__) + '/../../spec_helper.rb'
require 'ostruct'
require 'reek/method_context'
require 'reek/smells/uncommunicative_name'

include Reek
include Reek::Smells

describe UncommunicativeName, "method name" do
  it 'should not report one-word method name' do
    'def help(fred) basics(17) end'.should_not reek
  end
  it 'should report one-letter method name' do
    'def x(fred) basics(17) end'.should reek_only_of(:UncommunicativeName, /x/)
  end
  it 'should report name of the form "x2"' do
    'def x2(fred) basics(17) end'.should reek_only_of(:UncommunicativeName, /x2/)
  end
end

describe UncommunicativeName, "field name" do
  it 'should not report one-word field name' do
    'class Thing; def help(fred) @simple end end'.should_not reek
  end
  it 'should report one-letter fieldname' do
    'class Thing; def simple(fred) @x end end'.should reek_only_of(:UncommunicativeName, /@x/, /Thing/, /variable name/)
  end
  it 'should report name of the form "x2"' do
    'class Thing; def simple(fred) @x2 end end'.should reek_only_of(:UncommunicativeName, /@x2/, /Thing/, /variable name/)
  end
  it 'should report one-letter fieldname in assignment' do
    'class Thing; def simple(fred) @x = fred end end'.should reek_only_of(:UncommunicativeName, /@x/, /Thing/, /variable name/)
  end
end

describe UncommunicativeName, "local variable name" do
  it 'should not report one-word variable name' do
    'def help(fred) simple = jim(45) end'.should_not reek
  end
  it 'should report one-letter variable name' do
    'def simple(fred) x = jim(45) end'.should reek_only_of(:UncommunicativeName, /x/, /variable name/)
  end
  it 'should report name of the form "x2"' do
    'def simple(fred) x2 = jim(45) end'.should reek_only_of(:UncommunicativeName, /x2/, /variable name/)
  end
  it 'should report variable name only once' do
    'def simple(fred) x = jim(45); x = y end'.should reek_only_of(:UncommunicativeName, /x/)
  end
end

describe UncommunicativeName, "parameter name" do
  it 'should not recognise *' do
    'def help(xray, *) basics(17) end'.should_not reek
  end
  it "should report parameter's name" do
    'def help(x) basics(17) end'.should reek_only_of(:UncommunicativeName, /x/, /variable name/)
  end
  it 'should report name of the form "x2"' do
    'def help(x2) basics(17) end'.should reek_only_of(:UncommunicativeName, /x2/, /variable name/)
  end
end

describe UncommunicativeName, "block parameter name" do
  it "should report parameter's name" do
    'def help() @stuff.each {|x|} end'.should reek_only_of(:UncommunicativeName, /x/, /block/, /variable name/)
  end
  
  it "should report method name via if context" do
    src = <<EOS
def bad
  unless @mod then
    @sig.each { |x| x.to_s }
  end
end
EOS
    src.should reek_only_of(:UncommunicativeName, /'x'/)
  end
end

describe UncommunicativeName, "several names" do

  it 'should report all bad names' do
    ruby = Source.from_s('class Oof; def y(x) @z = x end end')
    ruby.should reek_of(:UncommunicativeName, /'x'/)
    ruby.should reek_of(:UncommunicativeName, /'y'/)
    ruby.should reek_of(:UncommunicativeName, /'@z'/)
  end

  it 'should report all bad block parameters' do
    source =<<EOS
class Thing
  def bad(fred)
    @fred.each {|x| 4 - x }
    @jim.each {|y| y - 4 }
  end
end
EOS
    source.should reek_of(:UncommunicativeName, /'x'/)
    source.should reek_of(:UncommunicativeName, /'y'/)
  end
end

describe UncommunicativeName, '#examine' do
  before :each do
    @report = Report.new
    @uc = UncommunicativeName.new
  end
  
  it 'should return true when reporting a smell' do
    mc = MethodContext.new(StopContext.new, [:defn, :x, nil])
    @uc.examine(mc, @report).should == true
  end
  
  it 'should return false when not reporting a smell' do
    mc = MethodContext.new(StopContext.new, [:defn, :not_bad, nil])
    @uc.examine(mc, @report).should == false
  end
end
