require_relative '../../spec_helper'
require_relative '../../../lib/reek/examiner'
require_relative '../../../lib/reek/cli/report/report'
require_relative '../../../lib/reek/cli/report/formatter'

describe Reek::Cli::Report::JsonReport do
  let(:instance) { Reek::Cli::Report::JsonReport.new }

  context 'empty source' do
    let(:examiner) { Reek::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'prints empty json' do
      expect { instance.show }.to output(/^\[\]$/).to_stdout
    end
  end
end
