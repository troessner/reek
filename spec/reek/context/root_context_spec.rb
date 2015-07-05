require_relative '../../spec_helper'
require_relative '../../../lib/reek/context/root_context'

RSpec.describe Reek::Context::RootContext do
  before :each do
    @root = Reek::Context::RootContext.new
  end

  context 'full_name' do
    it 'reports full context' do
      expect(@root.full_name).to eq('')
    end
  end
end
