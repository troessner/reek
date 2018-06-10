require_relative '../spec_helper'

RSpec.describe Reek::DocumentationLink do
  describe '.build' do
    it 'returns the correct link for a smell type' do
      expect(described_class.build('FeatureEnvy')).
        to eq "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/Feature-Envy.md"
    end

    it 'returns the correct link for general documentation' do
      expect(described_class.build('Rake Task')).
        to eq "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/Rake-Task.md"
    end

    it 'returns the correct link for subjects with abbreviations' do
      expect(described_class.build('YAML Report')).
        to eq "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/YAML-Report.md"
    end
  end
end
