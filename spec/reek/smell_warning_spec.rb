require 'spec_helper'
require 'reek/smell_warning'

include Reek

describe SmellWarning do
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
        @first  = build(:smell_warning, class_name: 'Duplication')
        @second = build(:smell_warning, class_name: 'FeatureEnvy')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by context' do
      before :each do
        @first  = build(:smell_warning, class_name: 'Duplication', context: 'first')
        @second = build(:smell_warning, class_name: 'Duplication', context: 'second')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by message' do
      before :each do
        @first  = build(:smell_warning, class_name: 'Duplication', context: 'ctx', message: 'first message')
        @second = build(:smell_warning, class_name: 'Duplication', context: 'ctx', message: 'second message')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'message takes precedence over smell name' do
      before :each do
        @first  = build(:smell_warning, class_name: 'UtilityFunction', message: 'first message')
        @second = build(:smell_warning, class_name: 'FeatureEnvy',     message: 'second message')
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing everywhere' do
      before :each do
        @first  = build(:smell_warning, class_name: 'UncommunicativeName',
                                        context: 'Dirty',   
                                        message: "has the variable name '@s'",
                                        source: true)
        @second = build(:smell_warning, class_name: 'Duplication',
                                        context: 'Dirty#a',
                                        message: 'calls @s.title twice',
                                        source: false)
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
      it 'includes the smell class' do
        expect(@yaml).to match(/class:\s*FeatureEnvy/)
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
        @subclass = 'TooManyParties'
        @parameters = { 'one' => 34, 'two' => 'second' }
        @warning = SmellWarning.new(@class, @context_name, @lines, @message,
                                    @source, @subclass, @parameters)
        @yaml = @warning.to_yaml
      end

      it_should_behave_like 'common fields'

      it 'includes the subclass' do
        expect(@yaml).to match(/subclass:\s*#{@subclass}/)
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

    context 'with all defaults used' do
      before :each do
        warning = SmellWarning.new(@class, @context_name, @lines, @message)
        @yaml = warning.to_yaml
      end

      it_should_behave_like 'common fields'

      it 'includes no subclass' do
        expect(@yaml).to match(/subclass: ["']{2}/)
      end
      it 'includes no source' do
        expect(@yaml).to match(/source: ["']{2}/)
      end
      it 'includes empty parameters' do
        expect(@yaml).not_to match(/parameter/)
      end
    end
  end
end
