require File.dirname(__FILE__) + '/../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'module_context')
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'singleton_method_context')
require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'stop_context')

include Reek

describe SingletonMethodContext do
  it "reports full context" do
    element = StopContext.new
    element = ModuleContext.new(element, 'mod', s(:module, :mod, nil))
    element = SingletonMethodContext.new(element, s(:defs, s(:call, nil, :a, s(:arglist)), :b, s(:args)))
    element.full_name.should match(/mod#a\.b/)
  end
end
