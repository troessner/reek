require_relative '../../spec_helper'
require_lib 'reek/rake/task'

RSpec.describe Reek::Rake::Task do
  describe '#source_files' do
    it 'is set to "lib/**/*.rb" by default' do
      task = described_class.new
      expect(task.source_files).to eq FileList['lib/**/*.rb']
    end
  end

  describe '#source_files=' do
    it 'sets source_files to a FileList when passed a string' do
      task = described_class.new
      task.source_files = '*.rb'
      expect(task.source_files).to eq FileList['*.rb']
    end
  end

  # SMELL: Testing a private method
  describe '#command' do
    let(:task) { described_class.new }

    it 'does not include a config file by default' do
      expect(task.send(:command)).not_to include '-c'
    end

    it 'includes a config file when set' do
      task.config_file = 'foo.reek'
      expect(task.send(:command)[1..2]).to eq ['-c', 'foo.reek']
    end
  end
end
