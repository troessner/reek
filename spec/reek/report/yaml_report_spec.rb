require_relative '../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/yaml_report'
require_lib 'reek/report/formatter'

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
      expected = YAML.safe_load <<-EOS.strip_heredoc
        ---
        - context:        "simple"
          lines:
          - 1
          message:        "has the parameter name 'a'"
          smell_type:     "UncommunicativeParameterName"
          source:         "string"
          name:           "a"
        - context:        "simple"
          lines:
          - 1
          message:        "doesn't depend on instance state (maybe move it to another class?)"
          smell_type:     "UtilityFunction"
          source:         "string"
      EOS

      expect(result).to eq expected
    end
    context 'with link formatter' do
      let(:options) { { warning_formatter: Reek::Report::Formatter::WikiLinkWarningFormatter.new } }

      it 'prints documentation links' do
        out = StringIO.new
        instance.show(out)
        out.rewind
        result = YAML.safe_load(out.read)
        expected = YAML.safe_load <<-EOS.strip_heredoc
          ---
          - context:        "simple"
            lines:
            - 1
            message:        "has the parameter name 'a'"
            smell_type:     "UncommunicativeParameterName"
            source:         "string"
            name:           "a"
            wiki_link:      "https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md"
          - context:        "simple"
            lines:
            - 1
            message:        "doesn't depend on instance state (maybe move it to another class?)"
            smell_type:     "UtilityFunction"
            source:         "string"
            wiki_link:      "https://github.com/troessner/reek/blob/master/docs/Utility-Function.md"
        EOS

        expect(result).to eq expected
      end
    end
  end
end
