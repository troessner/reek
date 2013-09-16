require 'spec_helper'
require 'reek/core/sniffer'

describe Hash do
  before :each do
    @first = {
      'one' => {'two' => 3, 'three' => 4},
      'two' => {'four' => true}
    }
  end

  it 'should deep merge Hashes' do
    other = Hash.new {|hash,key| hash[key] = {} }
    other['one']['gunk'] = 45
    other['two']['four'] = false
    other.push_keys(@first)
    @first['two']['four'].should == false
    @first['one'].keys.length.should == 3
  end

  it 'should deep copy Hashes' do
    second = @first.deep_copy
    second['two'].object_id.should_not be_eql(@first['two'].object_id)
  end

  it 'should merge array values' do
    @first['three'] = [1,2,3]
  end
end

describe Hash, 'merging arrays' do
  it 'should merge array values' do
    first = {'key' => {'one' => [1,2,3]}}
    second = {'key' => {'one' => [4,5]}}
    second.push_keys(first)
    first['key']['one'].should == [1,2,3,4,5]
  end
end
