require_relative '../../spec_helper'
require_relative '../../../lib/reek/examiner'
require_relative '../../../lib/reek/report/report'
require_relative '../../../lib/reek/report/formatter'

RSpec.describe Reek::Report::JSONReport do
  let(:instance) { Reek::Report::JSONReport.new }

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
