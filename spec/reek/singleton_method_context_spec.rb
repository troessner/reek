require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/module_context'
require 'reek/singleton_method_context'
require 'reek/stop_context'

include Reek

describe SingletonMethodContext, 'outer_name' do

  it "should report full context" do
    element = StopContext.new
    element = ModuleContext.new(element, Name.new(:mod), s(:module, :mod, nil))
    element = SingletonMethodContext.new(element, s(:defs, s(:call, nil, :a, s(:arglist)), :b, s(:args)))
    element.outer_name.should match(/mod::a\.b/)
  end
end
