require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/smell_repository'

describe Reek::Core::SmellRepository do
  describe '.smell_types' do
    let(:smell_types) { Reek::Core::SmellRepository.smell_types }

    it 'should include existing smell_types' do
      expect(smell_types).to include(Reek::Smells::IrresponsibleModule)
      expect(smell_types).to include(Reek::Smells::TooManyStatements)
    end

    it 'should exclude certain smell_types' do
      expect(smell_types).to_not include(Reek::Smells::SmellDetector)
    end

    it 'should return the smell types in alphabetic order' do
      expect(smell_types).to eq(smell_types.sort_by(&:name))
    end
  end
end
