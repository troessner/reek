require 'spec/reek/code_checks'
require 'reek/smells/duplication'

include CodeChecks
include Reek::Smells

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
    @dup = Duplication.new
  end

  it 'should return true when reporting a smell' do
    @mc.calls = {'x' => 47}
    @dup.examine(@mc, []).should == true
  end
  
  it 'should return false when not reporting a smell' do
    @mc.calls = []
    @dup.examine(@mc, []).should == false
  end
  
  it 'should return false when not reporting calls to new' do
    @mc.calls = {[:call, :Set, :new] => 4}
    @dup.examine(@mc, []).should == false
  end
end

describe Duplication, 'when disabled' do
  before :each do
    @ctx = MethodContext.new(StopContext.new, [0, :double_thing])
    @dup = Duplication.new({SmellDetector::ENABLED_KEY => false})
    @rpt = Report.new
  end

  it 'should not report repeated call' do
    @ctx.record_call_to([:fred])
    @ctx.record_call_to([:fred])
    @dup.examine(@ctx, @rpt).should == false
    @rpt.length.should == 0
  end
end
