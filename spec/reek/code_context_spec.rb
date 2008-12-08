require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/block_context'
require 'reek/if_context'
require 'reek/class_context'
require 'reek/module_context'
require 'reek/method_context'
require 'reek/stop_context'

include Reek

describe CodeContext, 'to_s' do

  it "should report full context" do
    element = StopContext.new
    element = ModuleContext.new(element, [0, :mod])
    element = ClassContext.new(element, [0, :klass])
    element = MethodContext.new(element, [0, :bad])
    element = BlockContext.new(element, nil)
    element.to_s.should match(/bad/)
    element.to_s.should match(/klass/)
    element.to_s.should match(/mod/)
  end

  it "should report method name via if context" do
    element1 = StopContext.new
    element2 = MethodContext.new(element1, [0, :bad])
    element3 = IfContext.new(element2, [0,1])
    BlockContext.new(element3, nil).to_s.should match(/bad/)
  end

  it "should report method name via nested blocks" do
    element1 = StopContext.new
    element2 = MethodContext.new(element1, [0, :bad])
    element3 = BlockContext.new(element2, nil)
    BlockContext.new(element3, nil).to_s.should match(/bad/)
  end
end

describe CodeContext, 'instance variables' do
  it 'should pass instance variables down to the first class' do
    element = StopContext.new
    element = ModuleContext.new(element, [0, :mod])
    class_element = ClassContext.new(element, [0, :klass])
    element = MethodContext.new(class_element, [0, :bad])
    element = BlockContext.new(element, nil)
    element.record_instance_variable(:fred)
    class_element.variable_names.should == [Name.new(:fred)]
  end
end
