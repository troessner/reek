require_relative '../../spec_helper'
require_relative '../../../lib/reek/sexp/sexp_formatter'

RSpec.describe Reek::Sexp::SexpFormatter do
  describe '::format' do
    it 'formats a simple s-expression' do
      result = described_class.format s(:lvar, :foo)
      expect(result).to eq('foo')
    end

    it 'formats a more complex s-expression' do
      ast = s(:send, nil, :foo, s(:lvar, :bar))
      result = described_class.format(ast)
      expect(result).to eq('foo(bar)')
    end

    it 'reduces very large ASTs to a single line' do
      ast = s(:if,
              s(:send, nil, :foo),
              s(:send, nil, :bar),
              s(:begin,
                s(:send, nil, :baz),
                s(:send, nil, :qux)))
      result = described_class.format ast

      expect(result).to eq 'if foo ... end'
    end

    it "doesn't reduce two-line ASTs" do
      ast = s(:def, 'my_method', s(:args))
      result = described_class.format ast
      expect(result).to eq 'def my_method; end'
    end
  end
end
