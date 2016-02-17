require_relative '../../spec_helper'
require_lib 'reek/cli/application'

RSpec.describe Reek::CLI::Application do
  describe '#initialize' do
    it 'exits with default error code on invalid options' do
      call = lambda do
        Reek::CLI::Silencer.silently do
          Reek::CLI::Application.new ['--foo']
        end
      end
      expect(call).to raise_error(SystemExit) do |error|
        expect(error.status).to eq Reek::CLI::Options::DEFAULT_ERROR_EXIT_CODE
      end
    end
  end

  context 'report_command' do
    describe '#execute' do
      let(:command) { double 'reek_command' }
      let(:app) { Reek::CLI::Application.new [] }

      before do
        allow(Reek::CLI::Command::ReportCommand).to receive(:new).and_return command
      end

      it "returns the command's result code" do
        allow(command).to receive(:execute).and_return 'foo'
        expect(app.execute).to eq 'foo'
      end
    end
  end
end
