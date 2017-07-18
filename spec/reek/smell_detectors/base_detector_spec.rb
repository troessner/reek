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

      before do
        expect(subclass.default_config['exclude']).to eq ['initialize']
      end

      it 'includes default exclusions' do
        detector = subclass.new
        smell = create(:smell_warning, smell_detector: detector, context: 'Foo#bar')
        result = subclass.todo_configuration_for([smell])

        expect(result).to eq('TooManyStatements' => { 'exclude' => ['initialize', 'Foo#bar'] })
      end
    end
  end

  describe 'unnecessary suppression' do
    class Reek::SmellDetectors::UselessDetector < described_class
      def sniff(_)
        []
      end
    end

    let(:subclass) { Reek::SmellDetectors::UselessDetector }

    it 'is reported when a method is unnecessarily disabled' do
      src = <<-EOS
        # :reek:UselessDetector
        def alfa(bravo); end
      EOS

      expect(src).to reek_of(:UselessDetector,
                             lines:   [],
                             context: 'alfa',
                             message: "is unnecessarily suppressed",
                             source:  'string')
    end

    it 'is reported when a method is unnecessarily excluded' do
      src = <<-EOS
        # :reek:UselessDetector { exclude: ['bravo'] }
        class Alfa
          def bravo
          end
        end
      EOS

      expect(src).to reek_of(:UselessDetector,
                             lines:   [],
                             context: 'Alfa#bravo',
                             message: "is unnecessarily suppressed",
                             source:  'string')
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
