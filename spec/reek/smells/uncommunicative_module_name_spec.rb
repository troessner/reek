require_relative '../../spec_helper'
require_lib 'reek/smells/uncommunicative_module_name'
require_relative 'smell_detector_shared'
require_lib 'reek/context/code_context'

RSpec.describe Reek::Smells::UncommunicativeModuleName do
  let(:detector) { build(:smell_detector, smell_type: :UncommunicativeModuleName) }

  it_should_behave_like 'SmellDetector'

  ['class', 'module'].each do |type|
    it 'does not report one-word name' do
      expect("#{type} Helper; end").not_to reek_of(:UncommunicativeModuleName)
    end

    it 'reports one-letter name' do
      expect("#{type} X; end").to reek_of(:UncommunicativeModuleName, name: 'X')
    end

    it 'reports name of the form "x2"' do
      expect("#{type} X2; end").to reek_of(:UncommunicativeModuleName, name: 'X2')
    end

    it 'reports long name ending in a number' do
      expect("#{type} Printer2; end").to reek_of(:UncommunicativeModuleName, name: 'Printer2')
    end

    it 'reports a bad scoped name' do
      src = "#{type} Foo::X; end"
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      smells = detector.inspect(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_category).to eq(Reek::Smells::UncommunicativeModuleName.smell_category)
      expect(smells[0].smell_type).to eq(Reek::Smells::UncommunicativeModuleName.smell_type)
      expect(smells[0].parameters[:name]).to eq('X')
      expect(smells[0].context).to match(/#{smells[0].parameters[:name]}/)
    end
  end

  context 'accept patterns' do
    let(:configuration) do
      default_directive_for_smell = {
        default_directive: {
          Reek::Smells::UncommunicativeModuleName => {
            'accept' => ['Inline::C']
          }
        }
      }
      Reek::Configuration::AppConfiguration.from_map(default_directive_for_smell)
    end

    it 'make smelly name pass' do
      src = 'module Inline::C; end'

      expect(src).to_not reek_of(described_class, {}, configuration)
    end

    it 'reports names with typos' do
      src = 'module Inline::K; end'

      expect(src).to reek_of(described_class, {}, configuration)
    end
  end

  context 'looking at the YAML' do
    let(:warning) do
      src = 'module Printer2; end'
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      detector.inspect(ctx).first
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(warning.parameters[:name]).to eq('Printer2')
      expect(warning.lines).to eq([1])
    end
  end
end
