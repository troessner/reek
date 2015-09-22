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
                                              smell_type: 'UncommunicativeVariableName',
                                              source: true)
        build(:smell_warning, smell_detector: uncommunicative_name_detector,
                              context: 'Dirty',
                              message: "has the variable name '@s'")
      end

      let(:second) do
        duplication_detector = build(:smell_detector,
                                     smell_type: 'DuplicateMethodCall',
                                     source: false)
        build(:smell_warning, smell_detector: duplication_detector,
                              context: 'Dirty#a',
                              message: 'calls @s.title twice')
      end

      it_should_behave_like 'first sorts ahead of second'
    end
  end

  context '#matches?' do
    let(:uncommunicative) do
      uncommunicative_name_detector = build(:smell_detector,
                                            smell_type: 'UncommunicativeVariableName')
      build(:smell_warning, smell_detector: uncommunicative_name_detector,
                            message: "has the variable name '@s'",
                            parameters: { test: 'something' })
    end

    it 'matches on class symbol' do
      expect(uncommunicative.matches?(:UncommunicativeVariableName)).to\
        be_truthy
    end

    it 'matches on class symbol and params' do
      expect(uncommunicative.matches?(:UncommunicativeVariableName,
                                      parameters: {
                                        test: 'something'
                                      })).to be_truthy
    end

    it 'matches on class symbol, params and attributes' do
      expect(uncommunicative.matches?(:UncommunicativeVariableName,
                                      parameters: { test: 'something' },
                                      message: "has the variable name '@s'"
                                     )).to be_truthy
    end

    it 'does not match on different class symbol' do
      expect(uncommunicative.matches?(:FeatureEnvy)).to be_falsy
    end

    it 'does not match on different params' do
      expect(uncommunicative.matches?(:UncommunicativeVariableName,
                                      parameters: {
                                        test: 'something else'
                                      })).to be_falsy
    end

    it 'does not match on different attributes' do
      expect(uncommunicative.matches?(:UncommunicativeVariableName,
                                      parameters: { test: 'something' },
                                      message: 'nothing')).to be_falsy
    end

    it 'raises error on uncomparable attribute' do
      expect do
        uncommunicative.matches?(:UncommunicativeVariableName,
                                 parameters: { test: 'something' },
                                 random: 'nothing')
      end.to raise_error("The attribute 'random' is not available for comparison")
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
