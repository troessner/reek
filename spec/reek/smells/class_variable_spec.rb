require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/class_variable'
require 'reek/class_context'

require 'spec/reek/smells/behaves_like_variable_detector'

include Reek
include Reek::Smells

describe ClassVariable do
  before :each do
    @detector = ClassVariable.new
    @record_variable = :record_class_variable
  end

  [ClassContext, ModuleContext].each do |klass|
    context "in a #{klass}" do
      before :each do
        @ctx = klass.create(StopContext.new, "Fred")
      end

      it_should_behave_like 'a variable detector'
    end
  end
end
