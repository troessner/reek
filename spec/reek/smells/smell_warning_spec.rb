require_relative '../../spec_helper'
require_lib 'reek/smells/smell_warning'

RSpec.describe Reek::Smells::SmellWarning do
  let(:duplication_detector)  { build(:smell_detector, smell_type: 'DuplicateMethodCall') }
  let(:feature_envy_detector) { build(:smell_detector, smell_type: 'FeatureEnvy') }
  let(:utility_function_detector) { build(:smell_detector, smell_type: 'UtilityFunction') }

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
        expect(second).not_to eql(first)
      end
    end

    context 'smells differing only by detector' do
      let(:first) { build(:smell_warning, smell_detector: duplication_detector) }
      let(:second) { build(:smell_warning, smell_detector: feature_envy_detector) }

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by context' do
      let(:first) { build(:smell_warning, smell_detector: duplication_detector, context: 'first') }
      let(:second) do
        build(:smell_warning, smell_detector: duplication_detector, context: 'second')
      end

      it_should_behave_like 'first sorts ahead of second'
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

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'message takes precedence over smell name' do
      let(:first) do
        build(:smell_warning, smell_detector: utility_function_detector, message: 'first message')
      end
      let(:second) do
        build(:smell_warning, smell_detector: feature_envy_detector, message: 'second message')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing everywhere' do
      let(:first) do
        uncommunicative_name_detector = build(:smell_detector,
                                              smell_type: 'UncommunicativeVariableName')
        build(:smell_warning, smell_detector: uncommunicative_name_detector,
                              context: 'Dirty',
                              message: "has the variable name '@s'")
      end

      let(:second) do
        duplication_detector = build(:smell_detector,
                                     smell_type: 'DuplicateMethodCall')
        build(:smell_warning, smell_detector: duplication_detector,
                              context: 'Dirty#a',
                              message: 'calls @s.title twice')
      end

      it_should_behave_like 'first sorts ahead of second'
    end
  end

  context '#yaml_hash' do
    let(:class) { 'FeatureEnvy' }
    let(:context_name) { 'Module::Class#method/block' }
    let(:lines) { [24, 513] }
    let(:message) { 'test message' }

    shared_examples_for 'common fields' do
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
    end

    context 'with all details specified' do
      let(:detector) { Reek::Smells::FeatureEnvy.new }
      let(:parameters) { { 'one' => 34, 'two' => 'second' } }
      let(:smell_type) { 'FeatureEnvy' }
      let(:source) { 'a/ruby/source/file.rb' }
      let(:yaml) do
        warning = Reek::Smells::SmellWarning.new(detector, source: source,
                                                           context: context_name,
                                                           lines: lines,
                                                           message: message,
                                                           parameters: parameters)
        warning.yaml_hash
      end

      it_should_behave_like 'common fields'

      it 'includes the smell type' do
        expect(yaml['smell_type']).to eq smell_type
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
end
