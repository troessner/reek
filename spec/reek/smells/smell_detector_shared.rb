require_relative '../../spec_helper'

RSpec.shared_examples_for 'SmellDetector' do
  context 'exception matching follows the context' do
    let(:ctx) { double('context') }

    before { allow(ctx).to receive(:config_for).and_return({}) }

    it 'when false' do
      expect(ctx).to receive(:matches?).at_least(:once).and_return(false)
      expect(detector.exception?(ctx)).to eq(false)
    end

    it 'when true' do
      expect(ctx).to receive(:matches?).at_least(:once).and_return(true)
      expect(detector.exception?(ctx)).to eq(true)
    end
  end
end

RSpec.shared_examples_for 'common fields set correctly' do
  it 'reports the source' do
    expect(warning.source).to eq('string')
  end

  it 'reports the smell class' do
    expect(warning.smell_category).to eq(detector.smell_category)
  end

  it 'reports the smell sub class' do
    expect(warning.smell_type).to eq(detector.smell_type)
  end
end
