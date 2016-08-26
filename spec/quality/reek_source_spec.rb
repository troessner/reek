require_relative '../spec_helper'

RSpec.describe 'Reek source code' do
  it 'has no smells' do
    Pathname.glob('lib/**/*.rb').each do |pathname|
      expect(pathname).not_to reek
    end
  end
end
