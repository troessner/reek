require 'spec_helper'

require 'reek/cli/options'

describe Reek::Cli::OptionInterpreter do
  let(:options) { OpenStruct.new }
  let(:instance) { Reek::Cli::OptionInterpreter.new(options) }

  describe '#reporter' do
    it 'returns a Report::TextReport instance by default' do
      expect(instance.reporter).to be_instance_of Reek::Cli::Report::TextReport
    end
  end
end
