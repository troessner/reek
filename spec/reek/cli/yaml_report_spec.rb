require_relative '../../spec_helper'
require_relative '../../../lib/reek/examiner'
require_relative '../../../lib/reek/cli/report/report'
require_relative '../../../lib/reek/cli/report/formatter'

include Reek
include Reek::CLI

describe Report::YAMLReport do
  let(:instance) { Report::YAMLReport.new }

  context 'empty source' do
    let(:examiner) { Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'prints empty yaml' do
      expect { instance.show }.to output(/^--- \[\]\n.*$/).to_stdout
    end
  end
end
