require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/reek/examiner'
require_relative '../../../lib/reek/report/report'
require_relative '../../../lib/reek/report/formatter'

RSpec.describe Reek::Report::XMLReport do
  let(:instance) { Reek::Report::XMLReport.new }

  context 'empty source' do
    let(:examiner) { Reek::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'prints empty checkstyle xml' do
      expect { instance.show }.to output("<?xml version='1.0'?>\n<checkstyle/>\n").to_stdout
    end
  end

  context 'source with voliations' do
    let(:examiner) { Reek::Examiner.new('def simple(a) a[0] end') }

    before do
      allow(File).to receive(:realpath).and_return('/some/path')
      instance.add_examiner examiner
    end

    it 'prints non-empty checkstyle xml' do
      sample_path = Pathname("#{__dir__}/../../samples/checkstyle.xml")
      expect { instance.show }.to output(sample_path.read).to_stdout
    end
  end
end
