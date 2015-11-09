require_relative '../../spec_helper'
require_lib 'reek/smells/uncommunicative_method_name'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::UncommunicativeMethodName do
  let(:detector) { build(:smell_detector, smell_type: :UncommunicativeMethodName) }

  it_should_behave_like 'SmellDetector'

  ['help', '+', '-', '/', '*'].each do |method_name|
    it "accepts the method name '#{method_name}'" do
      src = "def #{method_name}(arg) basics(17) end"
      expect(src).not_to reek_of(:UncommunicativeMethodName)
    end
  end

  ['x', 'x2', 'method2'].each do |method_name|
    context 'with a bad name' do
      let(:warning) do
        src = "def #{method_name}; end"
        ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
        detector.inspect(ctx).first
      end

      it_should_behave_like 'common fields set correctly'

      it 'reports the correct values' do
        expect(warning.parameters[:name]).to eq(method_name)
        expect(warning.lines).to eq([1])
        expect(warning.context).to eq(method_name)
      end
    end
  end
end
