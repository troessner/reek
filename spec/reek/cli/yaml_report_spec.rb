require 'spec_helper'
require 'reek/examiner'
require 'reek/cli/report/report'
require 'reek/cli/report/formatter'

include Reek
include Reek::Cli

describe Report::YamlReport do
  let(:instance) { Report::YamlReport.new }

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
