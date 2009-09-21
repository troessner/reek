require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/class_variable'
require 'reek/class_context'

include Reek
include Reek::Smells

describe ClassVariable do
  before :each do
    @klass = ClassContext.create(StopContext.new, "Fred")
    @detector = ClassVariable.new
  end

  context 'no class variables' do
    it "doesn't record a smell" do
      @detector.examine_context(@klass)
      @detector.num_smells.should == 0
    end
  end

  context 'one class variable' do
    before :each do
      @klass.record_class_variable(:@@cvar)
      @detector.examine_context(@klass)
    end

    it 'records a smell' do
      @detector.num_smells.should == 1
    end
    it 'mentions the variable name in the report' do
      @detector.should have_smell([/@@cvar/])
    end
  end

  context 'one class variable encountered twice' do
    before :each do
      @klass.record_class_variable(:@@cvar)
      @klass.record_class_variable(:@@cvar)
      @detector.examine_context(@klass)
    end

    it 'records only one smell' do
      @detector.num_smells.should == 1
    end
    it 'mentions the variable name in the report' do
      @detector.should have_smell([/@@cvar/])
    end
  end

  context 'two class variables' do
    before :each do
      @klass.record_class_variable(:@@cvar)
      @klass.record_class_variable(:@@another)
      @detector.examine_context(@klass)
    end

    it 'records a smell' do
      @detector.num_smells.should == 2
    end
    it 'mentions both variable names in the report' do
      @detector.should have_smell([/@@cvar/])
      @detector.should have_smell([/@@another/])
    end
  end
end
