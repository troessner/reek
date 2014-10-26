require 'spec_helper'
require 'reek/core/warning_collector'
require 'reek/smell_warning'

include Reek::Core

describe WarningCollector do
  before(:each) do
    @collector = WarningCollector.new
  end

  context 'when empty' do
    it 'reports no warnings' do
      expect(@collector.warnings).to eq([])
    end
  end

  context 'with one warning' do
    before :each do
      @warning = Reek::SmellWarning.new('ControlCouple', 'fred', [1, 2, 3], 'hello')
      @collector.found_smell(@warning)
    end
    it 'reports that warning' do
      expect(@collector.warnings).to eq([@warning])
    end
  end
end
