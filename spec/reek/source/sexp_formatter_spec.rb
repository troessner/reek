require_relative '../../spec_helper'
require_relative '../../../lib/reek/source/sexp_formatter'

describe Reek::Source::SexpFormatter do
  describe '::format' do
    it 'formats a simple s-expression' do
      result = Reek::Source::SexpFormatter.format s(:lvar, :foo)
      expect(result).to eq('foo')
    end

    it 'formats a more complex s-expression' do
      ast = s(:send, nil, :foo, s(:lvar, :bar))
      result = Reek::Source::SexpFormatter.format(ast)
      expect(result).to eq('foo(bar)')
    end

    it 'reduces very large ASTs to a single line' do
      ast = s(:if,
              s(:send, nil, :foo),
              s(:send, nil, :bar),
              s(:begin,
                s(:send, nil, :baz),
                s(:send, nil, :qux)))
      result = Reek::Source::SexpFormatter.format ast

      expect(result).to eq 'if foo ... end'
    end
  end
end
