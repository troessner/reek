require 'spec_helper'
require 'reek/smells/uncommunicative_parameter_name'
require 'reek/smells/smell_detector_shared'
require 'reek/core/method_context'

include Reek::Core
include Reek::Smells

describe UncommunicativeParameterName do
  before :each do
    @source_name = 'wallamalloo'
    @detector = UncommunicativeParameterName.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context "parameter name" do
    ['obj.', ''].each do |host|
      it 'does not recognise *' do
        "def #{host}help(xray, *) basics(17) end".should_not smell_of(UncommunicativeParameterName)
      end
      it "reports parameter's name" do
        src = "def #{host}help(x) basics(17) end"
        src.should smell_of(UncommunicativeParameterName, {UncommunicativeParameterName::PARAMETER_NAME_KEY => 'x'})
      end

      context 'with a name of the form "x2"' do
        before :each do
          @bad_param = 'x2'
          src = "def #{host}help(#{@bad_param}) basics(17) end"
          ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
          @smells = @detector.examine_context(ctx)
        end
        it 'reports only 1 smell' do
          @smells.length.should == 1
        end
        it 'reports uncommunicative parameter name' do
          @smells[0].subclass.should == UncommunicativeParameterName::SMELL_SUBCLASS
        end
        it 'reports the parameter name' do
          @smells[0].smell[UncommunicativeParameterName::PARAMETER_NAME_KEY].should == @bad_param
        end
      end
      it 'reports long name ending in a number' do
        @bad_param = 'param2'
        src = "def #{host}help(#{@bad_param}) basics(17) end"
        ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
        smells = @detector.examine_context(ctx)
        smells.length.should == 1
        smells[0].subclass.should == UncommunicativeParameterName::SMELL_SUBCLASS
        smells[0].smell[UncommunicativeParameterName::PARAMETER_NAME_KEY].should == @bad_param
      end
    end
  end

  context 'looking at the YAML' do
    before :each do
      src = 'def bad(good, bad2, good_again) end'
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      @warning.smell[UncommunicativeParameterName::PARAMETER_NAME_KEY].should == 'bad2'
      @warning.lines.should == [1]
    end
  end
end
