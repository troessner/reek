require File.dirname(__FILE__) + '/../../spec_helper.rb'

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
    Duplication.enable
  end

  it 'should return true when reporting a smell' do
    @mc.calls = {'x' => 47}
    Duplication.examine(@mc, []).should == true
  end
  
  it 'should return false when not reporting a smell' do
    @mc.calls = []
    Duplication.examine(@mc, []).should == false
  end
  
  it 'should return false when not reporting calls to new' do
    @mc.calls = {[:call, :Set, :new] => 4}
    Duplication.examine(@mc, []).should == false
  end
end

describe Duplication, 'when disabled' do
  before :each do
    Duplication.disable
  end

  check 'should not report repeated call',
    'def double_thing() @other.thing + @other.thing end', []
  check 'should not report repeated call to lvar',
    'def double_thing() other[@thing] + other[@thing] end', []
  check 'should not report call parameters',
    'def double_thing() @other.thing(2,3) + @other.thing(2,3) end', []
  check 'should not report nested calls',
    'def double_thing() @other.thing.foo + @other.thing.foo end', []

  after :each do
    Duplication.enable
  end
end
