require_relative '../../spec_helper'
require_lib 'reek/context/root_context'

RSpec.describe Reek::Context::RootContext do
  context 'full_name' do
    it 'reports full context' do
      ast = Reek::Source::SourceCode.from('foo = 1').syntax_tree
      root = described_class.new(ast)
      expect(root.full_name).to eq('')
    end
  end
end
