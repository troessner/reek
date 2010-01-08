require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/block_context'
require 'reek/method_context'

include Reek

describe BlockContext do
  context 'full_name' do
    it "reports full context" do
      bctx = BlockContext.new(StopContext.new, s(nil, nil))
      bctx.full_name.should == 'block'
    end
    it 'uses / to connect to the class name' do
      element = StopContext.new
      element = ClassContext.new(element, :Fred, s(:class, :Fred))
      element = BlockContext.new(element, s(:iter, nil, s(:lasgn, :x), nil))
      element.full_name.should == 'Fred/block'
    end
    it 'uses / to connect to the module name' do
      element = StopContext.new
      element = ModuleContext.new(element, :Fred, s(:module, :Fred))
      element = BlockContext.new(element, s(:iter, nil, s(:lasgn, :x), nil))
      element.full_name.should == 'Fred/block'
    end
  end
end
