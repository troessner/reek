require 'spec_helper'
require 'reek/spec'

include Reek
include Reek::Spec

describe ShouldReekOnlyOf do
  before :each do
    @expected_smell_class = :NestedIterators
    @expected_context_name = 'SmellyClass#big_method'
    @matcher = ShouldReekOnlyOf.new(@expected_smell_class, [/#{@expected_context_name}/])
    @examiner = double('examiner').as_null_object
    @examiner.should_receive(:smells).and_return {smells}
    @match = @matcher.matches_examiner?(@examiner)
  end

  shared_examples_for 'no match' do
    it 'does not match' do
      @match.should be_false
    end
    context 'when a match was expected' do
      before :each do
        @source = 'the_path/to_a/source_file.rb'
        @examiner.should_receive(:description).and_return(@source)
      end
      it 'reports the source' do
        @matcher.failure_message_for_should.should match(@source)
      end
      it 'reports the expected smell class' do
        @matcher.failure_message_for_should.should match(@expected_smell_class.to_s)
      end
    end
  end

  context 'with no smells' do
    def smells
      []
    end

    it_should_behave_like 'no match'
  end

  context 'with 1 non-matching smell' do
    def smells
      [SmellWarning.new('ControlCouple', 'context', [1], 'any old message')]
    end

    it_should_behave_like 'no match'
  end

  context 'with 2 non-matching smells' do
    def smells
      [
        SmellWarning.new('ControlCouple', 'context', [1], 'any old message'),
        SmellWarning.new('FeatureEnvy', 'context', [1], 'any old message')
        ]
    end

    it_should_behave_like 'no match'
  end

  context 'with 1 non-matching and 1 matching smell' do
    def smells
      [
        SmellWarning.new('ControlCouple', 'context', [1], 'any old message'),
        SmellWarning.new(@expected_smell_class.to_s, 'context', [1], "message mentioning #{@expected_context_name}")
        ]
    end

    it_should_behave_like 'no match'
  end

  context 'with 1 matching smell' do
    def smells
      [SmellWarning.new(@expected_smell_class.to_s, nil, [1], "message mentioning #{@expected_context_name}")]
    end
    it 'matches' do
      @match.should be_true
    end
    it 'reports the expected smell when no match was expected' do
      @matcher.failure_message_for_should_not.should match(@expected_smell_class.to_s)
    end
    it 'reports the source when no match was expected' do
      source = 'the_path/to_a/source_file.rb'
      @examiner.should_receive(:description).and_return(source)
      @matcher.failure_message_for_should_not.should match(source)
    end
  end
end
