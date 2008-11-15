require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/method_checker'
require 'reek/smells/duplication'
require 'reek/report'

include Reek
include Reek::Smells

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

describe Duplication, "repeated method calls" do
  check 'should report repeated call',
    'def double_thing() @other.thing + @other.thing end', [[/@other.thing/]]
  check 'should report repeated call to lvar',
    'def double_thing() other[@thing] + other[@thing] end', [[/other\[@thing\]/]]
  check 'should report call parameters',
    'def double_thing() @other.thing(2,3) + @other.thing(2,3) end', [[/@other.thing\(2, 3\)/]]
  check 'should report nested calls',
    'def double_thing() @other.thing.foo + @other.thing.foo end', [[/@other.thing[^\.]/], [/@other.thing.foo/]]
  check 'should ignore calls to new',
    'def double_thing() @other.new + @other.new end', []
end

describe Duplication, "non-repeated method calls" do
  check 'should not report similar calls',
    'def equals(other) other.thing == self.thing end', []
  check 'should respect call parameters',
    'def double_thing() @other.thing(3) + @other.thing(2) end', []
end

require 'ostruct'

describe Duplication, '#examine' do
  
  before :each do
    @mc = OpenStruct.new
  end

  it 'should return true when reporting a smell' do
    @mc.calls = {'x' => 47}
    Duplication.examine(@mc, []).should == true
  end
  
  it 'should return false when not reporting a smell' do
    @mc.calls = []
    Duplication.examine(@mc, []).should == false
  end
end
