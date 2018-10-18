require_relative '../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/yaml_report'

require 'yaml'
require 'stringio'

RSpec.describe Reek::Report::YAMLReport do
  let(:options) { {} }
  let(:instance) { described_class.new(options) }
  let(:examiner) { Reek::Examiner.new(source) }

  before do
    instance.add_examiner examiner
  end

  context 'with empty source' do
    let(:source) { '' }

    it 'prints empty yaml' do
      expect { instance.show }.to output(/^--- \[\]\n.*$/).to_stdout
    end
  end

  context 'with smelly source' do
    let(:source) { 'def simple(a) a[3] end' }

    it 'prints smells as yaml' do
      out = StringIO.new
      instance.show(out)
      out.rewind
      result = YAML.safe_load(out.read)
      expected = YAML.safe_load <<~YAML
        ---
        - context:        "simple"
          lines:
          - 1
          message:            "has the parameter name 'a'"
          smell_type:         "UncommunicativeParameterName"
          source:             "string"
          name:               "a"
          documentation_link: "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/Uncommunicative-Parameter-Name.md"
        - context:        "simple"
          lines:
          - 1
          message:            "doesn't depend on instance state (maybe move it to another class?)"
          smell_type:         "UtilityFunction"
          source:             "string"
          documentation_link: "https://github.com/troessner/reek/blob/v#{Reek::Version::STRING}/docs/Utility-Function.md"
      YAML

      expect(result).to eq expected
    end
  end
end
