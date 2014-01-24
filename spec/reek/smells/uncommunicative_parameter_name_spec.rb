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

  { 'obj.' => 'with a receiveer',
    '' => 'without a receiver'}.each do |host, description|
    context "in a method definition #{description}" do
      it 'does not recognise *' do
        "def #{host}help(xray, *) basics(17) end".
          should_not smell_of(UncommunicativeParameterName)
      end

      it "reports parameter's name" do
        src = "def #{host}help(x) basics(x) end"
        src.should smell_of(UncommunicativeParameterName,
                            {UncommunicativeParameterName::PARAMETER_NAME_KEY => 'x'})
      end

      it "does not report unused parameters" do
        src = "def #{host}help(x) basics(17) end"
        src.should_not smell_of(UncommunicativeParameterName)
      end

      it 'does not report two-letter parameter names' do
        "def #{host}help(ab) basics(ab) end".
          should_not smell_of(UncommunicativeParameterName)
      end

      it 'reports names of the form "x2"' do
        src = "def #{host}help(x2) basics(x2) end"
        src.should smell_of(UncommunicativeParameterName,
                            {UncommunicativeParameterName::PARAMETER_NAME_KEY => 'x2'})
      end

      it 'reports long name ending in a number' do
        src = "def #{host}help(param2) basics(param2) end"
        src.should smell_of(UncommunicativeParameterName,
                            {UncommunicativeParameterName::PARAMETER_NAME_KEY => 'param2'})
      end

      it 'does not report unused anonymous parameter' do
        "def #{host}help(_) basics(17) end".
          should_not smell_of(UncommunicativeParameterName)
      end

      it 'reports used anonymous parameter' do
        "def #{host}help(_) basics(_) end".
          should smell_of(UncommunicativeParameterName)
      end

      it 'reports used parameters marked as unused' do
        "def #{host}help(_unused) basics(_unused) end".
          should smell_of(UncommunicativeParameterName)
      end
    end
  end

  context 'looking at the smell result fields' do
    before :each do
      src = 'def bad(good, bad2, good_again); basics(good, bad2, good_again); end'
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
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
