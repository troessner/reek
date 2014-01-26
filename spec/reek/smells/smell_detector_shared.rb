require 'spec_helper'
require 'reek/core/smell_configuration'

include Reek::Core

shared_examples_for 'SmellDetector' do
  context 'exception matching follows the context' do
    before :each do
      @ctx = double('context')
      allow(@ctx).to receive(:config_for).and_return({})
    end
    it 'when false' do
      @ctx.should_receive(:matches?).at_least(:once).and_return(false)
      @detector.exception?(@ctx).should == false
    end

    it 'when true' do
      @ctx.should_receive(:matches?).at_least(:once).and_return(true)
      @detector.exception?(@ctx).should == true
    end
  end

  context 'configuration' do
    it 'becomes disabled when disabled' do
      @detector.configure_with({SmellConfiguration::ENABLED_KEY => false})
      @detector.should_not be_enabled
    end
  end
end

shared_examples_for 'common fields set correctly' do
  it 'reports the source' do
    @warning.source.should == @source_name
  end
  it 'reports the class' do
    @warning.smell_class.should == @detector.class::SMELL_CLASS
  end
  it 'reports the subclass' do
    @warning.subclass.should == @detector.class::SMELL_SUBCLASS
  end
end
