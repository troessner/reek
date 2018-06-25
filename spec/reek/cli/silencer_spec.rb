require_relative '../../spec_helper'
require_lib 'reek/cli/silencer'

RSpec.describe Reek::CLI::Silencer do
  describe '.silently' do
    it 'blocks output from the block on $stdout' do
      expect { described_class.silently { puts 'Hi!' } }.not_to output.to_stdout
    end

    it 'blocks output from the block on $stderr' do
      expect { described_class.silently { warn 'Hi!' } }.not_to output.to_stderr
    end

    it 'restores output on $stdout after the block' do
      expect do
        described_class.silently { puts 'Hi!' }
        puts 'there!'
      end.to output("there!\n").to_stdout
    end

    it 'restores output on $stderr after the block' do
      expect do
        described_class.silently { warn 'Hi!' }
        warn 'there!'
      end.to output("there!\n").to_stderr
    end
  end
end
