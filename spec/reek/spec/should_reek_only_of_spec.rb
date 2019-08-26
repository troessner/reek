require_relative '../../spec_helper'
require_lib 'reek/spec'

RSpec.describe Reek::Spec::ShouldReekOnlyOf do
  let(:examiner) { instance_double('Reek::Examiner').as_null_object }
  let(:expected_context_name) { 'SmellyClass#big_method' }
  let(:expected_smell_type) { :NestedIterators }
  let(:matcher) { described_class.new(expected_smell_type) }
  let(:matcher_matches) { matcher.matches_examiner?(examiner) }

  before do
    allow(examiner).to receive(:smells) { smells }
    matcher_matches
  end

  shared_examples_for 'no match' do
    it 'does not match' do
      expect(matcher_matches).to be_falsey
    end

    context 'when a match was expected' do
      let(:source) { 'the_path/to_a/source_file.rb' }

      before { allow(examiner).to receive(:origin).and_return(source) }

      it 'reports the source' do
        expect(matcher.failure_message).to match(source)
      end

      it 'reports the expected smell class' do
        expect(matcher.failure_message).to match(expected_smell_type.to_s)
      end
    end
  end

  context 'with no smells' do
    let(:smells) { [] }

    it_behaves_like 'no match'
  end

  context 'with 1 non-matching smell' do
    let(:smells) { [build(:smell_warning, smell_type: 'ControlParameter')] }

    it_behaves_like 'no match'
  end

  context 'with 2 non-matching smells' do
    let(:smells) do
      [
        build(:smell_warning, smell_type: 'ControlParameter'),
        build(:smell_warning, smell_type: 'FeatureEnvy')
      ]
    end

    it_behaves_like 'no match'
  end

  context 'with 1 non-matching and 1 matching smell' do
    let(:smells) do
      [
        build(:smell_warning, smell_type: 'ControlParameter'),
        build(:smell_warning, smell_type: expected_smell_type.to_s,
                              message: "message mentioning #{expected_context_name}")
      ]
    end

    it_behaves_like 'no match'
  end

  context 'with 1 matching smell' do
    let(:smells) do
      [build(:smell_warning, smell_type: expected_smell_type.to_s,
                             message: "message mentioning #{expected_context_name}")]
    end

    it 'matches' do
      expect(matcher_matches).to be_truthy
    end

    it 'reports the expected smell when no match was expected' do
      expect(matcher.failure_message_when_negated).to match(expected_smell_type.to_s)
    end

    it 'reports the source when no match was expected' do
      source = 'the_path/to_a/source_file.rb'
      allow(examiner).to receive(:origin).and_return(source)
      expect(matcher.failure_message_when_negated).to match(source)
    end
  end
end
