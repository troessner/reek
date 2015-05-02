require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/examiner'
require_relative '../../../lib/reek/cli/report/report'
require_relative '../../../lib/reek/cli/report/formatter'

RSpec.describe Reek::CLI::Report::JSONReport do
  let(:instance) { Reek::CLI::Report::JSONReport.new }

  context 'empty source' do
    let(:examiner) { Reek::Core::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'prints empty json' do
      expect { instance.show }.to output(/^\[\]$/).to_stdout
    end
  end
end
