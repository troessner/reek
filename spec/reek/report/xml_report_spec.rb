require_relative '../../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/report/report'

RSpec.describe Reek::Report::XMLReport do
  let(:xml_report) { Reek::Report::XMLReport.new }

  context 'empty source' do
    it 'prints empty checkstyle XML' do
      xml_report.add_examiner Reek::Examiner.new('')
      xml = "<?xml version='1.0'?>\n<checkstyle/>\n"
      expect { xml_report.show }.to output(xml).to_stdout
    end
  end

  context 'source with voliations' do
    it 'prints non-empty checkstyle XML' do
      path = SAMPLES_PATH.join('two_smelly_files/dirty_one.rb')
      xml_report.add_examiner Reek::Examiner.new(path)
      xml = SAMPLES_PATH.join('checkstyle.xml').read
      xml = xml.gsub(path.to_s, path.expand_path.to_s)
      expect { xml_report.show }.to output(xml).to_stdout
    end
  end
end
