require_relative '../spec_helper'
require_lib 'reek/smell_warning'

RSpec.describe Reek::SmellWarning do
  let(:uncommunicative_name_detector) { build(:smell_detector, smell_type: 'UncommunicativeVariableName') }

  describe 'sort order' do
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

    context 'when smells differ only by detector' do
      let(:first) { build(:smell_warning, smell_type: 'DuplicateMethodCall') }
      let(:second) { build(:smell_warning, smell_type: 'FeatureEnvy') }

      it_behaves_like 'first sorts ahead of second'
    end

    context 'when smells differ only by lines' do
      let(:first) { build(:smell_warning, smell_type: 'FeatureEnvy', lines: [2]) }
      let(:second) { build(:smell_warning, smell_type: 'FeatureEnvy', lines: [3]) }

      it_behaves_like 'first sorts ahead of second'
    end

    context 'when smells differ only by context' do
      let(:first) { build(:smell_warning, smell_type: 'DuplicateMethodCall', context: 'first') }
      let(:second) do
        build(:smell_warning, smell_type: 'DuplicateMethodCall', context: 'second')
      end

      it_behaves_like 'first sorts ahead of second'
    end

    context 'when smells differ only by message' do
      let(:first) do
        build(:smell_warning, smell_type: 'DuplicateMethodCall',
                              context: 'ctx', message: 'first message')
      end
      let(:second) do
        build(:smell_warning, smell_type: 'DuplicateMethodCall',
                              context: 'ctx', message: 'second message')
      end

      it_behaves_like 'first sorts ahead of second'
    end

    context 'when smells differ by name and message' do
      let(:first) do
        build(:smell_warning, smell_type: 'FeatureEnvy', message: 'second message')
      end
      let(:second) do
        build(:smell_warning, smell_type: 'UtilityFunction', message: 'first message')
      end

      it_behaves_like 'first sorts ahead of second'
    end

    context 'when smells differ everywhere' do
      let(:first) do
        build(:smell_warning, smell_type: 'DuplicateMethodCall',
                              context: 'Dirty#a',
                              message: 'calls @s.title twice')
      end

      let(:second) do
        build(:smell_warning, smell_type: 'UncommunicativeVariableName',
                              context: 'Dirty',
                              message: "has the variable name '@s'")
      end

      it_behaves_like 'first sorts ahead of second'
    end
  end

  describe '#yaml_hash' do
    let(:context_name) { 'Module::Class#method/block' }
    let(:lines) { [24, 513] }
    let(:message) { 'test message' }
    let(:parameters) { { 'one' => 34, 'two' => 'second' } }
    let(:smell_type) { 'FeatureEnvy' }
    let(:source) { 'a/ruby/source/file.rb' }

    let(:yaml) do
      warning = described_class.new(smell_type, source: source,
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

    it 'includes the documentation link' do
      expect(yaml['documentation_link']).to eq Reek::DocumentationLink.build('FeatureEnvy')
    end

    it 'includes the parameters' do
      parameters.each do |key, value|
        expect(yaml[key]).to eq value
      end
    end
  end
end
