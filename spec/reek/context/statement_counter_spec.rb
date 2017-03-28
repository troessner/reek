require_relative '../../spec_helper'
require_lib 'reek/context/statement_counter'

RSpec.describe Reek::Context::StatementCounter do
  let(:counter) { described_class.new }

  describe '#increase_by' do
    it 'does not increase if passed a falsy value' do
      counter.increase_by(nil)
      expect(counter.value).to eq 0
    end

    it 'increase by the lengh of the passed in argument' do
      counter.increase_by([1, 2, 3])
      expect(counter.value).to eq 3
    end

    it 'accumulates increases' do
      counter.increase_by([1, 2, 3])
      counter.increase_by([1, 2, 3])
      expect(counter.value).to eq 6
    end
  end
end
