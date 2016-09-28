require_relative '../../spec_helper'
require_lib 'reek/smells/smell_detector'
require_lib 'reek/smells/detector_repository'

RSpec.describe Reek::Smells::DetectorRepository do
  describe '.smell_types' do
    let(:smell_types) { described_class.smell_types }

    it 'includes existing smell_types' do
      expect(smell_types).to include(Reek::Smells::IrresponsibleModule).
        and include(Reek::Smells::TooManyStatements)
    end

    it 'excludes the smell detector base class' do
      expect(smell_types).not_to include(Reek::Smells::SmellDetector)
    end

    it 'returns the smell types in alphabetic order' do
      expect(smell_types).to eq(smell_types.sort_by(&:name))
    end
  end
end
