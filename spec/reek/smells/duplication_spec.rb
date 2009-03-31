require File.dirname(__FILE__) + '/../../spec_helper.rb'
require 'reek/report'
require 'reek/method_context'
require 'reek/stop_context'
require 'reek/smells/duplication'

include Reek
include Reek::Smells

describe Duplication, "repeated method calls" do
  it 'should report repeated call' do
    'def double_thing() @other.thing + @other.thing end'.should reek_only_of(:Duplication, /@other.thing/)
  end

  it 'should report repeated call to lvar' do
    'def double_thing() other[@thing] + other[@thing] end'.should reek_only_of(:Duplication, /other\[@thing\]/)
  end

  it 'should report call parameters' do
    'def double_thing() @other.thing(2,3) + @other.thing(2,3) end'.should reek_only_of(:Duplication, /@other.thing\(2, 3\)/)
  end

  it 'should report nested calls' do
    ruby = 'def double_thing() @other.thing.foo + @other.thing.foo end'.to_source
    ruby.should reek_of(:Duplication, /@other.thing[^\.]/)
    ruby.should reek_of(:Duplication, /@other.thing.foo/)
  end

  it 'should ignore calls to new' do
    'def double_thing() @other.new + @other.new end'.should_not reek
  end
end

describe Duplication, "non-repeated method calls" do
  it 'should not report similar calls' do
    'def equals(other) other.thing == self.thing end'.should_not reek
  end

  it 'should respect call parameters' do
    'def double_thing() @other.thing(3) + @other.thing(2) end'.should_not reek
  end
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
