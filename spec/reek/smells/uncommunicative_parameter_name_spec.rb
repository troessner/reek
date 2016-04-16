require_relative '../../spec_helper'
require_lib 'reek/smells/uncommunicative_parameter_name'
require_relative 'smell_detector_shared'
require_lib 'reek/context/method_context'

RSpec.describe Reek::Smells::UncommunicativeParameterName do
  let(:detector) { build(:smell_detector, smell_type: :UncommunicativeParameterName) }
  it_should_behave_like 'SmellDetector'

  { 'obj.' => 'with a receiver',
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

  describe 'inspect' do
    let(:source) { 'def foo(bar2); baz(bar2); end' }
    let(:context) { method_context(source) }
    let(:detector) { build(:smell_detector, smell_type: :UncommunicativeParameterName) }

    it 'returns an array of smell warnings' do
      smells = detector.inspect(context)
      expect(smells.length).to eq(1)
      expect(smells[0]).to be_a_kind_of(Reek::Smells::SmellWarning)
    end

    it 'contains proper smell warnings' do
      smells = detector.inspect(context)
      warning = smells[0]

      expect(warning.smell_type).to eq(Reek::Smells::UncommunicativeParameterName.smell_type)
      expect(warning.parameters[:name]).to eq('bar2')
      expect(warning.context).to match('foo')
      expect(warning.lines).to eq([1])
    end
  end

  describe '`accept` patterns' do
    let(:source) { 'def foo(bar2); baz(bar2); end' }

    it 'make smelly names pass via regex / strings given by list / literal' do
      [[/bar2/], /bar2/, ['bar2'], 'bar2'].each do |pattern|
        expect(source).to_not reek_of(described_class).with_config('accept' => pattern)
      end
    end
  end

  describe '`reject` patterns' do
    let(:source) { 'def foo(bar); baz(bar); end' }

    it 'reject smelly names via regex / strings given by list / literal' do
      [[/bar/], /bar/, ['bar'], 'bar'].each do |pattern|
        expect(source).to reek_of(described_class).with_config('reject' => pattern)
      end
    end
  end

  describe '.default_config' do
    it 'should merge in the default accept and reject patterns' do
      expected = {
        'enabled' => true,
        'exclude' => [],
        'reject'  => [/^.$/, /[0-9]$/, /[A-Z]/, /^_/],
        'accept'  => []
      }
      expect(described_class.default_config).to eq(expected)
    end
  end

  describe '.contexts' do
    it 'should be scoped to classes and modules' do
      expect(described_class.contexts).to eq([:def, :defs])
    end
  end
end
