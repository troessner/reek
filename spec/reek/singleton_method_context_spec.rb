require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/module_context'
require 'reek/singleton_method_context'
require 'reek/stop_context'

include Reek

describe SingletonMethodContext do
  it "reports full context" do
    element = StopContext.new
    element = ModuleContext.new(element, Name.new(:mod), s(:module, :mod, nil))
    element = SingletonMethodContext.new(element, s(:defs, s(:call, nil, :a, s(:arglist)), :b, s(:args)))
    element.full_name.should match(/mod#a\.b/)
  end
end
