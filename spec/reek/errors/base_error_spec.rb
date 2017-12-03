require_relative '../../spec_helper'

require_lib 'reek/errors/base_error'

RSpec.describe Reek::Errors::BaseError do
  let(:error) { described_class.new }

  describe '#long_message' do
    it 'returns the message' do
      expect(error.long_message).to eq error.message
    end
  end
end
