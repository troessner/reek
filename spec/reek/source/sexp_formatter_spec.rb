require 'spec_helper'
require 'reek/source/sexp_formatter'

include Reek::Source

describe SexpFormatter do
  describe '::format' do
    it 'formats a simple s-expression' do
      result = SexpFormatter.format s(:lvar, :foo)
      expect(result).to eq('foo')
    end

    it 'formats a more complex s-expression' do
      result = SexpFormatter.format s(:send, nil, :foo, s(:lvar, :bar))
      expect(result).to eq('foo(bar)')
    end

    it 'reduces very large ASTs to a single line' do
      ast = s(:if,
              s(:send, nil, :foo),
              s(:send, nil, :bar),
              s(:begin,
                s(:send, nil, :baz),
                s(:send, nil, :qux)))
      result = SexpFormatter.format ast

      expect(result).to eq 'if foo ... end'
    end
  end
end
