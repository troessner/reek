require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/base_detector'
require_lib 'reek/smell_detectors/duplicate_method_call'

RSpec.describe Reek::SmellDetectors::BaseDetector do
  describe '.todo_configuration_for' do
    it 'returns exclusion configuration for the given smells' do
      detector = described_class.new
      smell = create(:smell_warning, smell_detector: detector, context: 'Foo#bar')
      result = described_class.todo_configuration_for([smell])
      expect(result).to eq('BaseDetector' => { 'exclude' => ['Foo#bar'] })
    end

    it 'merges identical contexts' do
      detector = described_class.new
      smell = create(:smell_warning, smell_detector: detector, context: 'Foo#bar')
      result = described_class.todo_configuration_for([smell, smell])
      expect(result).to eq('BaseDetector' => { 'exclude' => ['Foo#bar'] })
    end

    context 'with default exclusions present' do
      let(:subclass) { Reek::SmellDetectors::TooManyStatements }

      it 'includes default exclusions' do
        detector = subclass.new
        smell = create(:smell_warning, smell_detector: detector, context: 'Foo#bar')
        result = subclass.todo_configuration_for([smell])

        aggregate_failures do
          expect(subclass.default_config['exclude']).to eq ['initialize']
          expect(result).to eq('TooManyStatements' => { 'exclude' => ['initialize', 'Foo#bar'] })
        end
      end
    end
  end

  describe '.valid_detector?' do
    it 'returns true for a valid detector' do
      expect(described_class.valid_detector?('DuplicateMethodCall')).to be true
    end

    it 'returns false for an invalid detector' do
      expect(described_class.valid_detector?('Unknown')).to be false
    end
  end

  describe '.to_detector' do
    it 'returns the right detector' do
      expect(described_class.to_detector('DuplicateMethodCall')).to eq(Reek::SmellDetectors::DuplicateMethodCall)
    end

    it 'raise NameError for an invalid detector name' do
      expect { described_class.to_detector('Unknown') }.to raise_error(NameError)
    end
  end

  describe '.configuration_keys' do
    it 'returns the right keys' do
      expected_keys = Reek::SmellDetectors::DuplicateMethodCall.configuration_keys.to_a
      expect(expected_keys).to eq([:enabled, :exclude, :max_calls, :allow_calls])
    end
  end
end
