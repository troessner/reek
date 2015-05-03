require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/examiner'
require_relative '../../../lib/reek/cli/report/report'

RSpec.describe Reek::CLI::Report::HTMLReport do
  let(:instance) { Reek::CLI::Report::HTMLReport.new }

  context 'with an empty source' do
    let(:examiner) { Reek::Core::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'has the text 0 total warnings' do
      instance.show

      file = File.expand_path('../../../../reek.html', __FILE__)
      text = File.read(file)
      File.delete(file)

      expect(text).to include('0 total warnings')
    end
  end
end
