require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smells/smells'
require 'yaml'

include Reek

describe 'Config' do
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
    @first.value_merge!(other).to_yaml
    @first['two']['four'].should == false
    @first['one'].keys.length.should == 3
  end
  
  it 'should deep copy Hashes' do
    second = @first.deep_copy
    second['two'].object_id.should_not be_eql(@first['two'].object_id)
  end
end
