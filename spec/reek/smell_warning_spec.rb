require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smell_warning'
require 'reek/smells/feature_envy'

include Reek

describe SmellWarning do
  context 'sort order' do
    context 'smells differing only by masking' do
      before :each do
        @first = SmellWarning.new('FeatureEnvy', "self", 27, "self", true)
        @second = SmellWarning.new('FeatureEnvy', "self", 27, "self", false)
      end

      it 'should hash equal when the smell is the same' do
        @first.hash.should == @second.hash
      end
      it 'should compare equal when the smell is the same' do
        @first.should == @second
      end
      it 'should compare equal when using <=>' do
        (@first <=> @second).should == 0
      end
      it 'matches using eql?' do
        @first.should eql(@second)
        @second.should eql(@first)
      end
    end

    shared_examples_for 'first sorts ahead of second' do
      it 'hash differently' do
        @first.hash.should_not == @second.hash
      end
      it 'are not equal' do
        @first.should_not == @second
      end
      it 'sort correctly' do
        (@first <=> @second).should be < 0
      end
      it 'does not match using eql?' do
        @first.should_not eql(@second)
        @second.should_not eql(@first)
      end
    end

    context 'smells differing only by detector' do
      before :each do
        @first = SmellWarning.new('Duplication', "self", 27, "self", false)
        @second = SmellWarning.new('FeatureEnvy', "self", 27, "self", true)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by context' do
      before :each do
        @first = SmellWarning.new('FeatureEnvy', "first", 27, "self", true)
        @second = SmellWarning.new('FeatureEnvy', "second", 27, "self", false)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by message' do
      before :each do
        @first = SmellWarning.new('FeatureEnvy', "context", 27, "first", true)
        @second = SmellWarning.new('FeatureEnvy', "context", 27, "second", false)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'message takes precedence over smell name' do
      before :each do
        @first = SmellWarning.new('UtilityFunction', "context", 27, "first", true)
        @second = SmellWarning.new('FeatureEnvy', "context", 27, "second", false)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing everywhere' do
      before :each do
        @first = SmellWarning.new('UncommunicativeName', "Dirty", 27, "has the variable name '@s'", true)
        @second = SmellWarning.new('Duplication', 'Dirty#a', 27, "calls @s.title twice", false)
      end

      it_should_behave_like 'first sorts ahead of second'
    end
  end

  context 'masked reporting' do
    class CountingReport
      attr_reader :masked, :non_masked
      def initialize
        @masked = @non_masked = 0
      end
      def found_smell(sw)
        @non_masked += 1
      end

      def found_masked_smell(sw)
        @masked += 1
      end
    end

    before :each do
      @masked = SmellWarning.new('FeatureEnvy', 'Fred', 27, "self", true)
      @visible = SmellWarning.new('FeatureEnvy', 'Fred', 27, "self", false)
    end

    it 'reports as masked when masked' do
      rpt = CountingReport.new
      @masked.report_on(rpt)
      rpt.masked.should == 1
      rpt.non_masked.should == 0
    end

    it 'reports as non-masked when non-masked' do
      rpt = CountingReport.new
      @visible.report_on(rpt)
      rpt.masked.should == 0
      rpt.non_masked.should == 1
    end
  end

  context 'YAML representation' do
    before :each do
      @message = 'test message'
      @lines = [24, 513]
      @class = 'FeatureEnvy'
      @context_name = 'Module::Class#method/block'
      @is_masked = true
      # Use a random string and a random bool
    end

    shared_examples_for 'common fields' do
      it 'includes the smell class' do
        @yaml.should match(/class:\s*FeatureEnvy/)
      end
      it 'includes the context' do
        @yaml.should match(/context:\s*#{@context_name}/)
      end
      it 'includes the message' do
        @yaml.should match(/message:\s*#{@message}/)
      end
      it 'indicates the masking' do
        @yaml.should match(/is_masked:\s*#{@is_masked}/)
      end
      it 'includes the line numbers' do
        @lines.each do |line|
          @yaml.should match(/lines:[\s\d-]*- #{line}/)
        end
      end
    end

    context 'with all details specified' do
      before :each do
        @source = 'a/ruby/source/file.rb'
        @subclass = 'TooManyParties'
        @parameters = {'one' => 34, 'two' => 'second'}
        warning = SmellWarning.new(@class, @context_name, @lines, @message, @is_masked,
          @source, @subclass, @parameters)
        @yaml = warning.to_yaml
      end

      it_should_behave_like 'common fields'

      it 'includes the subclass' do
        @yaml.should match(/subclass:\s*#{@subclass}/)
      end
      it 'includes the source' do
        @yaml.should match(/source:\s*#{@source}/)
      end
      it 'includes the parameters' do
        @parameters.each do |key,value|
          @yaml.should match(/#{key}:\s*#{value}/)
        end
      end
    end

    context 'with all defaults used' do
      before :each do
        warning = SmellWarning.new(@class, @context_name, @lines, @message, @is_masked)
        @yaml = warning.to_yaml
      end

      it_should_behave_like 'common fields'

      it 'includes no subclass' do
        @yaml.should match(/subclass:\s*""/)
      end
      it 'includes no source' do
        @yaml.should match(/source:\s*""/)
      end
      it 'includes empty parameters' do
        @yaml.should_not match(/parameter/)
      end
    end
  end
end
