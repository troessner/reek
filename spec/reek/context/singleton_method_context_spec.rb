require_relative '../../spec_helper'
require_lib 'reek/context/singleton_method_context'

RSpec.describe Reek::Context::SingletonMethodContext do
  let(:smc) do
    sexp = sexp(:def, :foo, sexp(:args, sexp(:arg, :bar)), nil)
    Reek::Context::SingletonMethodContext.new(nil, sexp)
  end

  describe '#envious_receivers' do
    it 'should not record envious calls' do
      smc.record_call_to sexp(:send, sexp(:lvar, :bar), :baz)
      expect(smc.envious_receivers).to be_empty
    end
  end
end
