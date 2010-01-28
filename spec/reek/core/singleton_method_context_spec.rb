require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'module_context')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'singleton_method_context')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'stop_context')

include Reek::Core

describe SingletonMethodContext do
  it "reports full context" do
    element = StopContext.new
    element = ModuleContext.new(element, 'mod', s(:module, :mod, nil))
    element = SingletonMethodContext.new(element, s(:defs, s(:call, nil, :a, s(:arglist)), :b, s(:args)))
    element.full_name.should match(/mod#a\.b/)
  end
end
