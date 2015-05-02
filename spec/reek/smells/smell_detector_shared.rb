require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/smell_configuration'

RSpec.shared_examples_for 'SmellDetector' do
  context 'exception matching follows the context' do
    before :each do
      @ctx = double('context')
      allow(@ctx).to receive(:config_for).and_return({})
    end

    it 'when false' do
      expect(@ctx).to receive(:matches?).at_least(:once).and_return(false)
      expect(@detector.exception?(@ctx)).to eq(false)
    end

    it 'when true' do
      expect(@ctx).to receive(:matches?).at_least(:once).and_return(true)
      expect(@detector.exception?(@ctx)).to eq(true)
    end
  end

  context 'configuration' do
    it 'becomes disabled when disabled' do
      enabled_key = Reek::Core::SmellConfiguration::ENABLED_KEY
      @detector.configure_with(enabled_key => false)
      expect(@detector).not_to be_enabled
    end
  end
end

RSpec.shared_examples_for 'common fields set correctly' do
  it 'reports the source' do
    expect(@warning.source).to eq(@source_name)
  end
  it 'reports the smell class' do
    expect(@warning.smell_category).to eq(@detector.smell_category)
  end
  it 'reports the smell sub class' do
    expect(@warning.smell_type).to eq(@detector.smell_type)
  end
end
