require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/uncommunicative_method_name'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::UncommunicativeMethodName do
  before do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :UncommunicativeMethodName, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  ['help', '+', '-', '/', '*'].each do |method_name|
    it "accepts the method name '#{method_name}'" do
      src = "def #{method_name}(fred) basics(17) end"
      expect(src).not_to reek_of(:UncommunicativeMethodName)
    end
  end

  ['x', 'x2', 'method2'].each do |method_name|
    context 'with a bad name' do
      before do
        src = "def #{method_name}; end"
        ctx = Reek::Core::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
        smells = @detector.examine_context(ctx)
        @warning = smells[0]
      end

      it_should_behave_like 'common fields set correctly'

      it 'reports the correct values' do
        expect(@warning.parameters[:name]).to eq(method_name)
        expect(@warning.lines).to eq([1])
        expect(@warning.context).to eq(method_name)
      end
    end
  end
end
