require_relative '../../spec_helper'
require_lib 'reek/cli/warning_collector'
require_lib 'reek/smells/smell_warning'

RSpec.describe Reek::CLI::WarningCollector do
  let(:collector) { described_class.new }

  context 'when empty' do
    it 'reports no warnings' do
      expect(collector.warnings).to eq([])
    end
  end

  context 'with one warning' do
    it 'reports that warning' do
      warning = Reek::Smells::SmellWarning.new(Reek::Smells::FeatureEnvy.new,
                                               source:  'string',
                                               context: 'foo',
                                               lines:   [1, 2, 3],
                                               message: 'hello')
      collector.found_smell(warning)
      expect(collector.warnings).to eq([warning])
    end
  end
end
