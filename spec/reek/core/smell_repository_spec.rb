require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/smell_repository'

include Reek::Core

describe SmellRepository do
  describe '.smell_types' do
    it 'should include existing smell_types' do
      expect(SmellRepository.smell_types).to include(Reek::Smells::IrresponsibleModule)
      expect(SmellRepository.smell_types).to include(Reek::Smells::TooManyStatements)
    end

    it 'should exclude certain smell_types' do
      expect(SmellRepository.smell_types).to_not include(Reek::Smells::SmellDetector)
    end
  end
end
