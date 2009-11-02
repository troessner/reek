require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/attribute'
require 'reek/class_context'

require 'spec/reek/smells/behaves_like_variable_detector'

include Reek
include Reek::Smells

describe Attribute do
  before :each do
    @detector = Attribute.new
    @record_variable = :record_attribute
  end

  [ClassContext, ModuleContext].each do |klass|
    context "in a #{klass}" do
      before :each do
        @ctx = klass.create(StopContext.new, s(:null, :Fred))
      end

      it_should_behave_like 'a variable detector'
    end
  end
end
