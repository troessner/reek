require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/smell_repository'

RSpec.describe Reek::Core::SmellRepository do
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

    it "should raise an ArgumentError if smell to configure doesn't exist" do
      repository = Reek::Core::SmellRepository.new
      expect { repository.configure('SomethingNonExistant', {}) }.
        to raise_error ArgumentError,
                       'Unknown smell type SomethingNonExistant found in configuration'
    end
  end
end
