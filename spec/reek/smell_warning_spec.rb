require_relative '../spec_helper'
require_lib 'reek/smell_warning'

RSpec.describe Reek::SmellWarning do
  let(:duplication_detector)  { build(:smell_detector, smell_type: 'DuplicateMethodCall') }
  let(:feature_envy_detector) { build(:smell_detector, smell_type: 'FeatureEnvy') }
  let(:utility_function_detector) { build(:smell_detector, smell_type: 'UtilityFunction') }
  let(:uncommunicative_name_detector) { build(:smell_detector, smell_type: 'UncommunicativeVariableName') }

  context 'sort order' do
    shared_examples_for 'first sorts ahead of second' do
      it 'hash differently' do
        expect(first.hash).not_to eq(second.hash)
      end

      it 'are not equal' do
        expect(first).not_to eq(second)
      end

      it 'sort correctly' do
        expect(first <=> second).to be < 0
      end

      it 'does not match using eql?' do
        expect(first).not_to eql(second)
      end
    end

    context 'smells differing only by detector' do
      let(:first) { build(:smell_warning, smell_detector: duplication_detector) }
      let(:second) { build(:smell_warning, smell_detector: feature_envy_detector) }

      it_behaves_like 'first sorts ahead of second'
    end

    context 'smells differing only by lines' do
      let(:first) { build(:smell_warning, smell_detector: feature_envy_detector, lines: [2]) }
      let(:second) { build(:smell_warning, smell_detector: feature_envy_detector, lines: [3]) }

      it_behaves_like 'first sorts ahead of second'
    end

    context 'smells differing only by context' do
      let(:first) { build(:smell_warning, smell_detector: duplication_detector, context: 'first') }
      let(:second) do
        build(:smell_warning, smell_detector: duplication_detector, context: 'second')
      end

      it_behaves_like 'first sorts ahead of second'
    end

    context 'smells differing only by message' do
      let(:first) do
        build(:smell_warning, smell_detector: duplication_detector,
                              context: 'ctx', message: 'first message')
      end
      let(:second) do
        build(:smell_warning, smell_detector: duplication_detector,
                              context: 'ctx', message: 'second message')
      end

      it_behaves_like 'first sorts ahead of second'
    end

    context 'smell name takes precedence over message' do
      let(:first) do
        build(:smell_warning, smell_detector: feature_envy_detector, message: 'second message')
      end
      let(:second) do
        build(:smell_warning, smell_detector: utility_function_detector, message: 'first message')
      end

      it_behaves_like 'first sorts ahead of second'
    end

    context 'smells differing everywhere' do
      let(:first) do
        build(:smell_warning, smell_detector: duplication_detector,
                              context: 'Dirty#a',
                              message: 'calls @s.title twice')
      end

      let(:second) do
        build(:smell_warning, smell_detector: uncommunicative_name_detector,
                              context: 'Dirty',
                              message: "has the variable name '@s'")
      end

      it_behaves_like 'first sorts ahead of second'
    end
  end

  describe '#smell_class' do
    it "returns the dectector's class" do
      warning = build(:smell_warning, smell_detector: duplication_detector)
      expect(warning.smell_class).to eq duplication_detector.class
    end
  end

  context '#yaml_hash' do
    let(:context_name) { 'Module::Class#method/block' }
    let(:lines) { [24, 513] }
    let(:message) { 'test message' }
    let(:detector) { Reek::SmellDetectors::FeatureEnvy.new }
    let(:parameters) { { 'one' => 34, 'two' => 'second' } }
    let(:smell_type) { 'FeatureEnvy' }
    let(:source) { 'a/ruby/source/file.rb' }

    let(:yaml) do
      warning = described_class.new(detector, source: source,
                                              context: context_name,
                                              lines: lines,
                                              message: message,
                                              parameters: parameters)
      warning.yaml_hash
    end

    it 'includes the smell type' do
      expect(yaml['smell_type']).to eq 'FeatureEnvy'
    end

    it 'includes the context' do
      expect(yaml['context']).to eq context_name
    end

    it 'includes the message' do
      expect(yaml['message']).to eq message
    end

    it 'includes the line numbers' do
      expect(yaml['lines']).to match_array lines
    end

    it 'includes the source' do
      expect(yaml['source']).to eq source
    end

    it 'includes the parameters' do
      parameters.each do |key, value|
        expect(yaml[key]).to eq value
      end
    end
  end
end
