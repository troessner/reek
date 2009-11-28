require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/smell_warning'
require 'reek/smells/feature_envy'

include Reek

describe SmellWarning do
  context 'sort order' do
    context 'smells differing only by masking' do
      before :each do
        @first = SmellWarning.new(Smells::FeatureEnvy.new, "self", 27, "self", true)
        @second = SmellWarning.new(Smells::FeatureEnvy.new, "self", 27, "self", false)
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
        @first = SmellWarning.new(Smells::Duplication.new, "self", 27, "self", false)
        @second = SmellWarning.new(Smells::FeatureEnvy.new, "self", 27, "self", true)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by context' do
      before :each do
        @first = SmellWarning.new(Smells::FeatureEnvy.new, "first", 27, "self", true)
        @second = SmellWarning.new(Smells::FeatureEnvy.new, "second", 27, "self", false)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing only by message' do
      before :each do
        @first = SmellWarning.new(Smells::FeatureEnvy.new, "context", 27, "first", true)
        @second = SmellWarning.new(Smells::FeatureEnvy.new, "context", 27, "second", false)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'message takes precedence over smell name' do
      before :each do
        @first = SmellWarning.new(Smells::UtilityFunction.new, "context", 27, "first", true)
        @second = SmellWarning.new(Smells::FeatureEnvy.new, "context", 27, "second", false)
      end

      it_should_behave_like 'first sorts ahead of second'
    end

    context 'smells differing everywhere' do
      before :each do
        @first = SmellWarning.new(Smells::UncommunicativeName.new, "Dirty", 27, "has the variable name '@s'", true)
        @second = SmellWarning.new(Smells::Duplication.new, 'Dirty#a', 27, "calls @s.title twice", false)
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
      @masked = SmellWarning.new(Smells::FeatureEnvy.new, 'Fred', 27, "self", true)
      @visible = SmellWarning.new(Smells::FeatureEnvy.new, 'Fred', 27, "self", false)
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
      @message = 'message'
      # Use a random string and a random bool
      warning = SmellWarning.new(Smells::FeatureEnvy.new, 'Fred', 27, @message, true)
      @yaml = warning.to_yaml
    end
    it 'includes the smell class' do
      @yaml.should match(/smell:\s*FeatureEnvy/)
    end
    it 'includes the context' do
      @yaml.should match(/context:\s*Fred/)
    end
    it 'includes the message' do
      @yaml.should match(/message:\s*#{@message}/)
    end
    it 'indicates the masking' do
      @yaml.should match(/is_masked:\s*true/)
    end
    it 'includes the line number' do
      @yaml.should match(/line:\s*27/)
    end
  end
end
