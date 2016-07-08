require_relative '../../spec_helper'
require_lib 'reek/smells/smell_detector'

RSpec.describe Reek::Smells::SmellDetector do
  describe 'exception handling' do
    describe 'catches all exceptions, enriches them and re-raises them' do
      it 'adds source file line number to the original exception' do
        skip
      end

      it 'adds source file name to the original exception' do
        skip
      end
    end
  end

  describe '.todo_configuration_for' do
    it 'returns exclusion configuration for the given smells' do
      detector = described_class.new
      smell = create(:smell_warning, smell_detector: detector, context: 'Foo#bar')
      result = described_class.todo_configuration_for([smell])
      expect(result).to eq('SmellDetector' => { 'exclude' => ['Foo#bar'] })
    end

    it 'merges identical contexts' do
      detector = described_class.new
      smell = create(:smell_warning, smell_detector: detector, context: 'Foo#bar')
      result = described_class.todo_configuration_for([smell, smell])
      expect(result).to eq('SmellDetector' => { 'exclude' => ['Foo#bar'] })
    end

    context 'with default exclusions present' do
      let(:subclass) { Reek::Smells::TooManyStatements }

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
end
