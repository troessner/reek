require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/attribute'
require 'reek/class_context'

include Reek
include Reek::Smells

describe Attribute do
  shared_examples_for 'an attribute detector' do
    context 'with no attributes' do
      it "doesn't record a smell" do
        @detector.examine_context(@ctx)
        @detector.num_smells.should == 0
      end
    end

    context 'with one attribute' do
      before :each do
        @ctx.record_attribute(:property)
        @detector.examine_context(@ctx)
      end

      it 'records a smell' do
        @detector.num_smells.should == 1
      end
      it 'mentions the variable name in the report' do
        @detector.should have_smell([/property/])
      end
    end

    context 'with one attribute encountered twice' do
      before :each do
        @ctx.record_attribute(:property)
        @ctx.record_attribute(:property)
        @detector.examine_context(@ctx)
      end

      it 'records only one smell' do
        @detector.num_smells.should == 1
      end
      it 'mentions the variable name in the report' do
        @detector.should have_smell([/property/])
      end
    end

    context 'with two attributes' do
      before :each do
        @ctx.record_attribute(:property)
        @ctx.record_attribute(:another)
        @detector.examine_context(@ctx)
      end

      it 'records a smell' do
        @detector.num_smells.should == 2
      end
      it 'mentions both variable names in the report' do
        @detector.should have_smell([/property/])
        @detector.should have_smell([/another/])
      end
    end
  end

  context 'in a class' do
    before :each do
      @ctx = ClassContext.create(StopContext.new, "Fred")
      @detector = Attribute.new
    end

    it_should_behave_like 'an attribute detector'
  end

  context 'in a module' do
    before :each do
      @ctx = ModuleContext.create(StopContext.new, "Fred")
      @detector = Attribute.new
    end

    it_should_behave_like 'an attribute detector'
  end
end
