require 'tempfile'
require_relative '../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/report'

RSpec.describe Reek::Report::HTMLReport do
  let(:instance) { Reek::Report::HTMLReport.new }

  context 'with an empty source' do
    let(:examiner) { Reek::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'has the text 0 total warnings' do
      tempfile = Tempfile.new(['Reek::Report::HTMLReport.', '.html'])
      response = "HTML file saved\n"
      expect { instance.show(target_path: tempfile.path) }.
        to output(response).to_stdout
      expect(tempfile.read).to include('0 total warnings')
    end
  end
end
