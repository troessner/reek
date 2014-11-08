require 'spec_helper'

describe 'Reek source code' do
  it 'has no smells' do
    Dir['lib/**/*.rb'].should_not reek
  end
end
