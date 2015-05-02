require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/stop_context'

RSpec.describe Reek::Core::StopContext do
  before :each do
    @stop = Reek::Core::StopContext.new
  end

  context 'full_name' do
    it 'reports full context' do
      expect(@stop.full_name).to eq('')
    end
  end
end
