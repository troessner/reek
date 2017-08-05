require_relative '../../spec_helper'
require_lib 'reek/rake/task'

RSpec.describe Reek::Rake::Task do
  describe '#source_files' do
    it 'is set to "lib/**/*.rb" by default' do
      task = described_class.new
      expect(task.source_files).to eq FileList['lib/**/*.rb']
    end

    it 'is set to ENV["REEK_SRC"]' do
      begin
        ENV['REEK_SRC'] = '*.rb'
        task = described_class.new
        expect(task.source_files).to eq FileList['*.rb']
      ensure
        ENV['REEK_SRC'] = nil
      end
    end
  end

  describe '#source_files=' do
    it 'sets source_files to a FileList when passed a string' do
      task = described_class.new do |it|
        it.source_files = '*.rb'
      end
      expect(task.source_files).to eq FileList['*.rb']
    end

    it 'has no effect when ENV["REEK_SRC"] is set' do
      begin
        ENV['REEK_SRC'] = '*.rb'
        task = described_class.new do |it|
          it.source_files = 'lib/*.rb'
        end
        expect(task.source_files).to eq FileList['*.rb']
      ensure
        ENV['REEK_SRC'] = nil
      end
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
