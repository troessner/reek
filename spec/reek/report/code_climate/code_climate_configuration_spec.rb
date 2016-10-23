require_relative '../../../spec_helper'
require_lib 'reek/report/code_climate/code_climate_configuration'

RSpec.describe Reek::Report::CodeClimateConfiguration do
  yml = described_class.load
  smell_types = Reek::SmellDetectors::BaseDetector.descendants.map do |descendant|
    descendant.name.demodulize
  end

  smell_types.each do |name|
    config = yml.fetch(name)
    it "provides remediation_points for #{name}" do
      expect(config['remediation_points']).to be_a Integer
    end

    it "provides content for #{name}" do
      expect(config['content']).to be_a String
    end
  end

  it 'does not include extraneous configuration' do
    expect(smell_types).to match_array(yml.keys)
  end
end
