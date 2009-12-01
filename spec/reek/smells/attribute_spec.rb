require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/attribute'
require 'reek/class_context'

include Reek
include Reek::Smells

describe Attribute do
  before :each do
    @detector = Attribute.new
  end
  context 'with no attributes' do
    it 'records nothing in the class' do
      ctx = ClassContext.from_s('class Fred; end')
      @detector.attributes_in(ctx).should be_empty
    end
    it 'records nothing in the module' do
      ctx = ModuleContext.from_s('module Fred; end')
      @detector.attributes_in(ctx).should be_empty
    end
  end

  context 'with one attribute' do
    shared_examples_for 'one attribute found' do
      it 'records the attribute' do
        @detector.attributes_in(@ctx).should include(:property)
      end
      it 'records only that attribute' do
        @detector.attributes_in(@ctx).length.should == 1
      end
    end

    context 'declared in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'reader in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr_reader :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'writer in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr_writer :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'accessor in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr_accessor :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'declared in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'reader in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr_reader :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'writer in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr_writer :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'accessor in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr_accessor :property; end')
      end

      it_should_behave_like 'one attribute found'
    end
  end
end

require 'spec/reek/smells/smell_detector_shared'

describe Attribute do
  before(:each) do
    @detector = Attribute.new
  end

  it_should_behave_like 'SmellDetector'
end
