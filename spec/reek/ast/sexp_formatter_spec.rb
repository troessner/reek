require_relative '../../spec_helper'
require_lib 'reek/ast/sexp_formatter'

RSpec.describe Reek::AST::SexpFormatter do
  describe '::format' do
    it 'formats a simple s-expression' do
      result = described_class.format sexp(:lvar, :foo)
      expect(result).to eq('foo')
    end

    it 'formats a more complex s-expression' do
      ast = sexp(:send, nil, :foo, sexp(:lvar, :bar))
      result = described_class.format(ast)
      expect(result).to eq('foo(bar)')
    end

    it 'reduces very large ASTs to a single line' do
      ast = sexp(:if,
                 sexp(:send, nil, :foo),
                 sexp(:send, nil, :bar),
                 sexp(:begin,
                      sexp(:send, nil, :baz),
                      sexp(:send, nil, :qux)))
      result = described_class.format ast

      expect(result).to eq 'if foo ... end'
    end

    it "doesn't reduce two-line ASTs" do
      ast = sexp(:def, 'my_method', sexp(:args))
      result = described_class.format ast
      expect(result).to eq 'def my_method; end'
    end
  end
end
