require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/singleton_method_context'
require_relative '../../../lib/reek/core/stop_context'

RSpec.describe Reek::Core::SingletonMethodContext do
  let(:smc) do
    sexp = s(:def, :foo, s(:args, s(:arg, :bar)), nil)
    Reek::Core::SingletonMethodContext.new(Reek::Core::StopContext.new, sexp)
  end

  describe '#envious_receivers' do
    it 'should not record envious calls' do
      smc.record_call_to s(:send, s(:lvar, :bar), :baz)
      expect(smc.envious_receivers).to be_empty
    end
  end
end
