require_relative '../spec_helper'

RSpec.describe Reek::DocumentationLink do
  describe '.build' do
    it 'returns the correct link for a smell type' do
      expect(described_class.build('FeatureEnvy')).
        to include(:html => "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/Feature-Envy.md",
                   :markdown => "https://raw.githubusercontent.com/troessner/reek/v#{Reek::Version::STRING}/docs/Feature-Envy.md")
    end

    it 'returns the correct link for general documentation' do
      expect(described_class.build('Rake Task')).
        to include(:html => "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/Rake-Task.md",
                   :markdown => "https://raw.githubusercontent.com/troessner/reek/v#{Reek::Version::STRING}/docs/Rake-Task.md")
    end

    it 'returns the correct link for subjects with abbreviations' do
      expect(described_class.build('YAML Report')).
        to include(:html => "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/YAML-Report.md",
                   :markdown => "https://raw.githubusercontent.com/troessner/reek/v#{Reek::Version::STRING}/docs/YAML-Report.md")
    end
  end
end
