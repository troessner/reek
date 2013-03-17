require 'spec_helper'
require 'reek/smells/uncommunicative_method_name'
require 'reek/smells/smell_detector_shared'
require 'reek/core/code_parser'
require 'reek/core/sniffer'

include Reek
include Reek::Smells

describe UncommunicativeMethodName do
  before :each do
    @source_name = 'wallamalloo'
    @detector = UncommunicativeMethodName.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  ['help', '+', '-', '/', '*'].each do |method_name|
    it "accepts the method name '#{method_name}'" do
      "def #{method_name}(fred) basics(17) end".should_not smell_of(UncommunicativeMethodName)
    end
  end

  ['x', 'x2', 'method2'].each do |method_name|
    context 'with a bad name' do
      before :each do
        src = 'def x() end'
        ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
        @smells = @detector.examine_context(ctx)
        @warning = @smells[0]
      end

      it_should_behave_like 'common fields set correctly'

      it 'reports the correct values' do
        @smells[0].smell[UncommunicativeMethodName::METHOD_NAME_KEY].should == 'x'
        @smells[0].lines.should == [1]
        @smells[0].context.should == 'x'
      end
    end
  end
end
