require_relative '../../spec_helper'
require_lib 'reek/configuration/default_directive'

RSpec.describe Reek::Configuration::DefaultDirective do
  describe '#add' do
    subject { {}.extend(described_class) }

    it 'adds a smell configuration' do
      subject.add :UncommunicativeVariableName, enabled: false
      expect(subject).to eq(Reek::Smells::UncommunicativeVariableName => { enabled: false })
    end
  end
end
