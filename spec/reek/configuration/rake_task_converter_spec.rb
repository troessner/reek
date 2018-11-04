require_relative '../../spec_helper'
require_lib 'reek/configuration/rake_task_converter'

RSpec.describe Reek::Configuration::RakeTaskConverter do
  describe 'convert' do
    let(:configuration_for_smell_detector) do
      {
        'exclude' => [/Klass#foobar$/, /^Klass#omg$/],
        'reject'  => [/^[a-z]$/, /[0-9]$/, /[A-Z]/],
        'accept'  => [/^_$/]
      }
    end

    let(:expected_exclude) { ['/Klass#foobar$/', '/^Klass#omg$/'] }
    let(:expected_reject) { ['/^[a-z]$/', '/[0-9]$/', '/[A-Z]/'] }
    let(:expected_accept) { ['/^_$/'] }

    it 'converts exclude regexes to strings' do
      converted_configuration = described_class.convert configuration_for_smell_detector
      expect(converted_configuration['exclude']).to eq(expected_exclude)
    end

    it 'converts reject regexes to strings' do
      converted_configuration = described_class.convert configuration_for_smell_detector
      expect(converted_configuration['reject']).to eq(expected_reject)
    end

    it 'converts accept regexes to strings' do
      converted_configuration = described_class.convert configuration_for_smell_detector
      expect(converted_configuration['accept']).to eq(expected_accept)
    end
  end
end
