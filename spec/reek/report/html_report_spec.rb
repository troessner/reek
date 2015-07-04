require_relative '../../spec_helper'
require_relative '../../../lib/reek/examiner'
require_relative '../../../lib/reek/report/report'

RSpec.describe Reek::Report::HTMLReport do
  let(:instance) { Reek::Report::HTMLReport.new }

  context 'with an empty source' do
    let(:examiner) { Reek::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'has the text 0 total warnings' do
      expect { instance.show }.to output(/0 total warnings/).to_stdout
    end
  end
end
