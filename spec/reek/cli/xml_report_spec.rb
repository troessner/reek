require_relative '../../spec_helper'
require_relative '../../../lib/reek/examiner'
require_relative '../../../lib/reek/cli/report/report'
require_relative '../../../lib/reek/cli/report/formatter'

describe Reek::CLI::Report::XMLReport do
  let(:instance) { Reek::CLI::Report::XMLReport.new }

  context 'empty source' do
    let(:examiner) { Reek::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'prints empty checkstyle xml' do
      expect { instance.show }.to output("<?xml version='1.0'?>\n<checkstyle/>\n").to_stdout
    end
  end
end
