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

      before { allow(examiner).to receive(:description).and_return(source) }

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
    let(:control_couple_detector) { build(:smell_detector, smell_type: 'ControlParameter') }
    let(:smells) { [build(:smell_warning, smell_detector: control_couple_detector)] }

    it_behaves_like 'no match'
  end

  context 'with 2 non-matching smells' do
    let(:control_couple_detector) { build(:smell_detector, smell_type: 'ControlParameter') }
    let(:feature_envy_detector) { build(:smell_detector, smell_type: 'FeatureEnvy') }
    let(:smells) do
      [
        build(:smell_warning, smell_detector: control_couple_detector),
        build(:smell_warning, smell_detector: feature_envy_detector)
      ]
    end

    it_behaves_like 'no match'
  end

  context 'with 1 non-matching and 1 matching smell' do
    let(:control_couple_detector) { build(:smell_detector, smell_type: 'ControlParameter') }
    let(:smells) do
      detector = build(:smell_detector, smell_type: expected_smell_type.to_s)
      [
        build(:smell_warning, smell_detector: control_couple_detector),
        build(:smell_warning, smell_detector: detector,
                              message: "message mentioning #{expected_context_name}")
      ]
    end

    it_behaves_like 'no match'
  end

  context 'with 1 matching smell' do
    let(:smells) do
      detector = build(:smell_detector, smell_type: expected_smell_type.to_s)

      [build(:smell_warning, smell_detector: detector,
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
      allow(examiner).to receive(:description).and_return(source)
      expect(matcher.failure_message_when_negated).to match(source)
    end
  end
end
