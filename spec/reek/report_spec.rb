require_relative '../spec_helper'
require_lib 'reek/report'

RSpec.describe Reek::Report do
  describe '.report_class' do
    it 'returns the correct class' do
      expect(Reek::Report.report_class(:text)).to eq Reek::Report::TextReport
    end
  end

  describe '.location_formatter' do
    it 'returns the correct class' do
      expect(Reek::Report.location_formatter(:plain)).to eq Reek::Report::BlankLocationFormatter
    end
  end

  describe '.heading_formatter' do
    it 'returns the correct class' do
      expect(Reek::Report.heading_formatter(:quiet)).to eq Reek::Report::HeadingFormatter::Quiet
    end
  end

  describe '.warning_formatter_class' do
    it 'returns the correct class' do
      expect(Reek::Report.warning_formatter_class(:simple)).to eq Reek::Report::SimpleWarningFormatter
    end
  end
end
