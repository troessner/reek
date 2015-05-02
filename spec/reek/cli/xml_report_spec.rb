require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/examiner'
require_relative '../../../lib/reek/cli/report/report'
require_relative '../../../lib/reek/cli/report/formatter'

RSpec.describe Reek::CLI::Report::XMLReport do
  let(:instance) { Reek::CLI::Report::XMLReport.new }

  context 'empty source' do
    let(:examiner) { Reek::Core::Examiner.new('') }

    before do
      instance.add_examiner examiner
    end

    it 'prints empty checkstyle xml' do
      expect { instance.show }.to output("<?xml version='1.0'?>\n<checkstyle/>\n").to_stdout
    end
  end

  context 'source with voliations' do
    let(:examiner) { Reek::Core::Examiner.new('def simple(a) a[0] end') }

    before do
      allow(File).to receive(:realpath).and_return('/some/path')
      instance.add_examiner examiner
    end

    it 'prints non-empty checkstyle xml' do
      sample_path = File.expand_path 'checkstyle.xml', 'spec/samples'
      expect { instance.show }.to output(File.read(sample_path)).to_stdout
    end
  end
end
