require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/uncommunicative_parameter_name'
require_relative 'smell_detector_shared'
require_relative '../../../lib/reek/context/method_context'

RSpec.describe Reek::Smells::UncommunicativeParameterName do
  before :each do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector,
                      smell_type: :UncommunicativeParameterName,
                      source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  { 'obj.' => 'with a receiveer',
    '' => 'without a receiver' }.each do |host, description|
    context "in a method definition #{description}" do
      it 'does not recognise *' do
        expect("def #{host}help(xray, *) basics(17) end").
          not_to reek_of(:UncommunicativeParameterName)
      end

      it "reports parameter's name" do
        src = "def #{host}help(x) basics(x) end"
        expect(src).to reek_of(:UncommunicativeParameterName,
                               name: 'x')
      end

      it 'does not report unused parameters' do
        src = "def #{host}help(x) basics(17) end"
        expect(src).not_to reek_of(:UncommunicativeParameterName)
      end

      it 'does not report two-letter parameter names' do
        expect("def #{host}help(ab) basics(ab) end").
          not_to reek_of(:UncommunicativeParameterName)
      end

      it 'reports names of the form "x2"' do
        src = "def #{host}help(x2) basics(x2) end"
        expect(src).to reek_of(:UncommunicativeParameterName,
                               name: 'x2')
      end

      it 'reports long name ending in a number' do
        src = "def #{host}help(param2) basics(param2) end"
        expect(src).to reek_of(:UncommunicativeParameterName,
                               name: 'param2')
      end

      it 'does not report unused anonymous parameter' do
        expect("def #{host}help(_) basics(17) end").
          not_to reek_of(:UncommunicativeParameterName)
      end

      it 'reports used anonymous parameter' do
        expect("def #{host}help(_) basics(_) end").
          to reek_of(:UncommunicativeParameterName)
      end

      it 'reports used parameters marked as unused' do
        expect("def #{host}help(_unused) basics(_unused) end").
          to reek_of(:UncommunicativeParameterName)
      end

      it 'reports names inside array decomposition' do
        src = "def #{host}help((b, nice)) basics(b, nice) end"
        expect(src).to reek_of(:UncommunicativeParameterName,
                               name: 'b')
      end

      it 'reports names inside nested array decomposition' do
        src = "def #{host}help((foo, (bar, c))) basics(foo, c) end"
        expect(src).to reek_of(:UncommunicativeParameterName,
                               name: 'c')
      end
    end
  end

  context 'looking at the smell result fields' do
    before :each do
      src = 'def bad(good, bad2, good_again); basics(good, bad2, good_again); end'
      ctx = Reek::Context::MethodContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(@warning.parameters[:name]).to eq('bad2')
      expect(@warning.lines).to eq([1])
    end
  end
end
