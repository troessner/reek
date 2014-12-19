require 'spec_helper'
require 'reek/smell_warning'

include Reek

describe SmellWarning do
  let(:duplication_detector)  { build(:smell_detector, smell_type: 'DuplicateMethodCall') }
  let(:feature_envy_detector) { build(:smell_detector, smell_type: 'FeatureEnvy') }
  let(:utility_function_detector) { build(:smell_detector, smell_type: 'UtilityFunction') }

  context 'sort order' do
    shared_examples_for 'first sorts ahead of second' do
      it 'hash differently' do
        expect(@first.hash).not_to eq(@second.hash)
      end
      it 'are not equal' do
        expect(@first).not_to eq(@second)
      end
      it 'sort correctly' do
        expect(@first <=> @second).to be < 0
      end
      it 'does not match using eql?' do
        expect(@first).not_to eql(@second)
        expect(@second).not_to eql(@first)
      end
    end

    context 'smells differing only by detector' do
      before :each do
        @first  = build(:smell_warning, smell_detector: duplication_detector)
        @second = build(:smell_warning, smell_detector: feature_envy_detector)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by context' do
      before :each do
        @first  = build(:smell_warning, smell_detector: duplication_detector,
                                        context: 'first')
        @second = build(:smell_warning, smell_detector: duplication_detector,
                                        context: 'second')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by message' do
      before :each do
        @first  = build(:smell_warning, smell_detector: duplication_detector,
                                        context: 'ctx',
                                        message: 'first message')
        @second = build(:smell_warning, smell_detector: duplication_detector,
                                        context: 'ctx',
                                        message: 'second message')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'message takes precedence over smell name' do
      before :each do
        @first  = build(:smell_warning, smell_detector: utility_function_detector,
                                        message: 'first message')
        @second = build(:smell_warning, smell_detector: feature_envy_detector,
                                        message: 'second message')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing everywhere' do
      before :each do
        uncommunicative_name_detector = build(:smell_detector,
                                              smell_type: 'UncommunicativeVariableName',
                                              source: true)
        duplication_detector = build(:smell_detector,
                                     smell_type: 'DuplicateMethodCall',
                                     source: false)
        @first  = build(:smell_warning, smell_detector: uncommunicative_name_detector,
                                        context: 'Dirty',
                                        message: "has the variable name '@s'")
        @second = build(:smell_warning, smell_detector: duplication_detector,
                                        context: 'Dirty#a',
                                        message: 'calls @s.title twice')
      end

      it_should_behave_like 'first sorts ahead of second'
    end
  end

  context 'YAML representation' do
    before :each do
      @message = 'test message'
      @lines = [24, 513]
      @class = 'FeatureEnvy'
      @context_name = 'Module::Class#method/block'
      # Use a random string and a random bool
    end

    shared_examples_for 'common fields' do
      it 'includes the smell type' do
        expect(@yaml).to match(/smell_type:\s*FeatureEnvy/)
      end
      it 'includes the context' do
        expect(@yaml).to match(/context:\s*#{@context_name}/)
      end
      it 'includes the message' do
        expect(@yaml).to match(/message:\s*#{@message}/)
      end
      it 'includes the line numbers' do
        @lines.each do |line|
          expect(@yaml).to match(/lines:[\s\d-]*- #{line}/)
        end
      end
    end

    context 'with all details specified' do
      before :each do
        @source = 'a/ruby/source/file.rb'
        @smell_type = 'FeatureEnvy'
        @parameters = { 'one' => 34, 'two' => 'second' }
        @detector = Reek::Smells::FeatureEnvy.new @source
        @warning = SmellWarning.new(@detector, context: @context_name,
                                               lines: @lines,
                                               message: @message,
                                               parameters: @parameters)
        @yaml = @warning.to_yaml
      end

      it_should_behave_like 'common fields'

      it 'includes the smell type' do
        expect(@yaml).to match(/smell_type:\s*#{@smell_type}/)
      end
      it 'includes the source' do
        expect(@yaml).to match(/source:\s*#{@source}/)
      end
      it 'includes the parameters' do
        @parameters.each do |key, value|
          expect(@yaml).to match(/#{key}:\s*#{value}/)
        end
      end
    end
  end
end
