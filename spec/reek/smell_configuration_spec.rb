require_relative '../spec_helper'
require_lib 'reek/smell_configuration'

RSpec.describe Reek::SmellConfiguration do
  context 'when overriding default configs' do
    let(:base_config) do
      {
        'accept'  => ['_'],
        'enabled' => true,
        'exclude' => [],
        'reject'  => [/^.$/, /[0-9]$/, /[A-Z]/]
      }
    end

    let(:smell_config) { described_class.new(base_config) }

    it { expect(smell_config.merge({})).to eq(base_config) }
    it { expect(smell_config.merge('enabled' => true)).to eq(base_config) }
    it { expect(smell_config.merge('exclude' => [])).to eq(base_config) }
    it { expect(smell_config.merge('accept' => ['_'])).to eq(base_config) }
    it do
      updated = smell_config.merge('reject' => [/^.$/, /[0-9]$/, /[A-Z]/])
      expect(updated).to eq(base_config)
    end
    it do
      updated = smell_config.merge('accept' => ['_'], 'enabled' => true)
      expect(updated).to eq(base_config)
    end

    it 'overrides single values' do
      updated = smell_config.merge('enabled' => false)
      expect(updated).to eq('accept'  => ['_'],
                            'enabled' => false,
                            'exclude' => [],
                            'reject'  => [/^.$/, /[0-9]$/, /[A-Z]/])
    end

    it 'overrides arrays of values' do
      updated = smell_config.merge('reject' => [/^.$/, /[3-9]$/])
      expect(updated).to eq('accept'  => ['_'],
                            'enabled' => true,
                            'exclude' => [],
                            'reject'  => [/^.$/, /[3-9]$/])
    end

    it 'overrides multiple values' do
      updated = smell_config.merge('accept' => [/[A-Z]$/], 'enabled' => false)
      expect(updated).to eq('accept'  => [/[A-Z]$/],
                            'enabled' => false,
                            'exclude' => [],
                            'reject'  => [/^.$/, /[0-9]$/, /[A-Z]/])
    end
  end
end
