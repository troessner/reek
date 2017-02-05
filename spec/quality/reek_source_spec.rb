require_relative '../spec_helper'

RSpec.describe 'Reek source code' do
  Pathname.glob('lib/**/*.rb').each do |pathname|
    describe pathname do
      it 'has no smells' do
        expect(pathname).not_to reek
      end
    end
  end
end
