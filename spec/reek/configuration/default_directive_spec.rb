require_relative '../../spec_helper'
require_lib 'reek/configuration/default_directive'

RSpec.describe Reek::Configuration::DefaultDirective do
  describe '#add' do
    let(:directives) { {}.extend(described_class) }

    it 'adds a smell configuration' do
      directives.add :UncommunicativeVariableName, enabled: false
      expect(directives).to eq(Reek::SmellDetectors::UncommunicativeVariableName => { enabled: false })
    end
  end
end
