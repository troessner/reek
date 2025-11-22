# frozen_string_literal: true

require_relative '../../spec_helper'
require_lib 'reek/code_climate/code_climate_configuration'

RSpec.describe Reek::CodeClimate::CodeClimateConfiguration do
  let(:yml) { described_class.load }

  Reek::SmellDetectors::BaseDetector.descendants.each do |detector|
    describe "for #{detector.smell_type}" do
      let(:config) { yml.fetch(detector.smell_type) }

      it 'provides remediation_points' do
        expect(config['remediation_points']).to be_a Integer
      end

      it 'provides content' do
        expect(config['content']).to be_a String
      end
    end
  end

  it 'does not include extraneous configuration' do
    smell_types = Reek::SmellDetectors::BaseDetector.descendants.map(&:smell_type)
    expect(smell_types).to match_array(yml.keys)
  end
end
