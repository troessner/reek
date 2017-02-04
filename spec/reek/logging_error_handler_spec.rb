require_relative '../spec_helper'
require_lib 'reek/logging_error_handler'

RSpec.describe Reek::LoggingErrorHandler do
  describe '#handle' do
    let(:exception) { RuntimeError.new('some message') }
    let(:handler) { described_class.new }

    it "outputs the exception's message to stderr" do
      expect { handler.handle(exception) }.
        to output(/some message/).to_stderr
    end

    it 'indicates the exception has been appropriately handled' do
      result = false

      Reek::CLI::Silencer.silently do
        result = handler.handle(exception)
      end

      expect(result).to be_truthy
    end
  end
end
