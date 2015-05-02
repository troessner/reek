require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/warning_collector'
require_relative '../../../lib/reek/smells/smell_warning'

RSpec.describe Reek::Core::WarningCollector do
  before(:each) do
    @collector = Reek::Core::WarningCollector.new
  end

  context 'when empty' do
    it 'reports no warnings' do
      expect(@collector.warnings).to eq([])
    end
  end

  context 'with one warning' do
    before :each do
      @warning = Reek::Smells::SmellWarning.new(Reek::Smells::FeatureEnvy.new(''),
                                                context: 'fred',
                                                lines:   [1, 2, 3],
                                                message: 'hello')
      @collector.found_smell(@warning)
    end
    it 'reports that warning' do
      expect(@collector.warnings).to eq([@warning])
    end
  end
end
