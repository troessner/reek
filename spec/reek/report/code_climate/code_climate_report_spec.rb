require_relative '../../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/code_climate'

require 'json'
require 'stringio'

RSpec.describe Reek::Report::CodeClimateReport do
  let(:options) { {} }
  let(:instance) { described_class.new(options) }
  let(:examiner) { Reek::Examiner.new(source) }

  before do
    instance.add_examiner examiner
  end

  context 'with empty source' do
    let(:source) { '' }

    it 'prints an empty string' do
      expect { instance.show }.to output('').to_stdout
    end
  end

  context 'with smelly source' do
    let(:source) { 'def simple(a) a[3] end' }

    it 'prints smells as json' do
      expected = <<-EOS.strip_heredoc.delete("\n")
        {\"type\":\"issue\",
        \"check_name\":\"UncommunicativeParameterName\",
        \"description\":\"simple has the parameter name 'a'\",
        \"categories\":[\"Complexity\"],
        \"location\":{\"path\":\"string\",\"lines\":{\"begin\":1,\"end\":1}},
        \"remediation_points\":150000,
        \"content\":{\"body\":\"An `Uncommunicative Parameter Name` is a parameter name that
         doesn't communicate its intent well enough.\\n\\nPoor names make it hard for the reader
         to build a mental picture of what's going on in the code. They can also be
         mis-interpreted; and they hurt the flow of reading, because the reader must slow down
         to interpret the names.\\n\"},
        \"fingerprint\":\"09970037d92b5a628bf682a3e2bb126d\"}\u0000
        {\"type\":\"issue\",
        \"check_name\":\"UtilityFunction\",
        \"description\":\"simple doesn't depend on instance state (maybe move it to another class?)\",
        \"categories\":[\"Complexity\"],
        \"location\":{\"path\":\"string\",\"lines\":{\"begin\":1,\"end\":1}},
        \"remediation_points\":250000,
        \"content\":{\"body\":\"A _Utility Function_ is any instance method that has no
         dependency on the state of the instance.\\n\"},
        \"fingerprint\":\"db456db7cb344bb5a98b8fc54a2f382e\"}\u0000
      EOS

      expect { instance.show }.to output(expected).to_stdout
    end
  end
end
