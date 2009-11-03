require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/tree_dresser'

include Reek

describe TreeDresser do
  before(:each) do
    @dresser = TreeDresser.new
  end

  it 'maps :if to IfNode' do
    @dresser.extensions_for(:if).should == 'IfNode'
  end

  it 'maps :call to CallNode' do
    @dresser.extensions_for(:call).should == 'CallNode'
  end
end

