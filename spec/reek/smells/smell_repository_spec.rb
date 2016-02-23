require_relative '../../spec_helper'
require_lib 'reek/smells/smell_detector'
require_lib 'reek/smells/smell_repository'

RSpec.describe Reek::Smells::SmellRepository do
  describe '.smell_types' do
    let(:smell_types) { described_class.smell_types }

    it 'should include existing smell_types' do
      expect(smell_types).to include(Reek::Smells::IrresponsibleModule)
      expect(smell_types).to include(Reek::Smells::TooManyStatements)
    end

    it 'should exclude the smell detector base class' do
      expect(smell_types).to_not include(Reek::Smells::SmellDetector)
    end

    it 'should return the smell types in alphabetic order' do
      expect(smell_types).to eq(smell_types.sort_by(&:name))
    end
  end

  describe '.eligible_smell_types' do
    it 'returns all smell detectors by default' do
      expect(described_class.eligible_smell_types).to eq described_class.smell_types
    end

    it 'returns smell detectors specified by type' do
      result = described_class.eligible_smell_types(['IrresponsibleModule', 'TooManyStatements'])
      expect(result).to eq [Reek::Smells::IrresponsibleModule,
                            Reek::Smells::TooManyStatements]
    end

    it 'returns smell detectors specified by category' do
      result = described_class.eligible_smell_types(['Duplication'])
      expect(result).to eq [Reek::Smells::DuplicateMethodCall]
    end
  end
end
