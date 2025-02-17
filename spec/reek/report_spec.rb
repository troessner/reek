# frozen_string_literal: true

require_relative '../spec_helper'
require_lib 'reek/report'

RSpec.describe Reek::Report do
  describe '.report_class' do
    it 'returns the correct class' do
      expect(described_class.report_class(:text)).to eq described_class::TextReport
    end
  end

  describe '.location_formatter' do
    it 'returns the correct class' do
      expect(described_class.location_formatter(:plain)).to eq described_class::BlankLocationFormatter
    end
  end

  describe '.heading_formatter' do
    it 'returns the correct class' do
      expect(described_class.heading_formatter(:quiet)).to eq described_class::QuietHeadingFormatter
    end
  end

  describe '.warning_formatter_class' do
    it 'returns the correct class' do
      expect(described_class.warning_formatter_class(:simple)).to eq described_class::SimpleWarningFormatter
    end
  end
end
