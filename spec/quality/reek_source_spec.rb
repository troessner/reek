require_relative '../spec_helper'

RSpec.describe 'Reek source code' do
  it 'has no smells' do
    expect(Dir['lib/**/*.rb']).to_not reek
  end
end
