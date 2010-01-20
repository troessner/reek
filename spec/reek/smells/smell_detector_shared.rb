#require File.dirname(__FILE__) + '/../../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'configuration')

include Reek

shared_examples_for 'SmellDetector' do
  context 'exception matching follows the context' do
    before :each do
      @ctx = mock('context')
    end
    it 'when false' do
      @ctx.should_receive(:matches?).and_return(false)
      @detector.exception?(@ctx).should == false
    end

    it 'when true' do
      @ctx.should_receive(:matches?).and_return(true)
      @detector.exception?(@ctx).should == true
    end
  end

  context 'configuration' do
    it 'becomes disabled when disabled' do
      @detector.configure({@detector.smell_type => {SmellConfiguration::ENABLED_KEY => false}})
      @detector.should_not be_enabled
    end
  end
end
