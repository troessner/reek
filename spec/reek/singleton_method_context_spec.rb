require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/module_context'
require 'reek/singleton_method_context'
require 'reek/stop_context'

include Reek

describe SingletonMethodContext, 'outer_name' do

  it "should report full context" do
    element = StopContext.new
    element = ModuleContext.new(element, [0, :mod])
    element = SingletonMethodContext.new(element,  [:defs, [:call, nil, :a, [:arglist]], :b, nil])
    element.outer_name.should match(/mod::a\.b/)
  end
end
