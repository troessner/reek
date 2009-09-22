require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/class_variable'
require 'reek/class_context'

include Reek
include Reek::Smells

describe ClassVariable do
  shared_examples_for 'a class variable container' do
    context 'no class variables' do
      it "doesn't record a smell" do
        @detector.examine_context(@ctx)
        @detector.num_smells.should == 0
      end
    end

    context 'one class variable' do
      before :each do
        @ctx.record_class_variable(:@@cvar)
        @detector.examine_context(@ctx)
      end

      it 'records a smell' do
        @detector.num_smells.should == 1
      end
      it 'mentions the variable name in the report' do
        @detector.should have_smell([/@@cvar/])
      end
    end

    context 'one class variable encountered twice' do
      before :each do
        @ctx.record_class_variable(:@@cvar)
        @ctx.record_class_variable(:@@cvar)
        @detector.examine_context(@ctx)
      end

      it 'records only one smell' do
        @detector.num_smells.should == 1
      end
      it 'mentions the variable name in the report' do
        @detector.should have_smell([/@@cvar/])
      end
    end

    context 'two class variables' do
      before :each do
        @ctx.record_class_variable(:@@cvar)
        @ctx.record_class_variable(:@@another)
        @detector.examine_context(@ctx)
      end

      it 'records a smell' do
        @detector.num_smells.should == 2
      end
      it 'mentions both variable names in the report' do
        @detector.should have_smell([/@@cvar/])
        @detector.should have_smell([/@@another/])
      end
    end
  end

  context 'in a class' do
    before :each do
      @ctx = ClassContext.create(StopContext.new, "Fred")
      @detector = ClassVariable.new
    end

    it_should_behave_like 'a class variable container'
  end

  context 'in a module' do
    before :each do
      @ctx = ModuleContext.create(StopContext.new, "Fred")
      @detector = ClassVariable.new
    end

    it_should_behave_like 'a class variable container'
  end
end
