require 'spec_helper'
require 'reek/source/sexp_formatter'

include Reek::Source

describe SexpFormatter do
  describe "::format" do
    it 'formats a simple s-expression' do
      result = SexpFormatter.format s(:lvar, :foo)
      expect(result).to eq("foo")
    end

    it 'formats a more complex s-expression' do
      result = SexpFormatter.format s(:call, nil, :foo, s(:arglist, s(:lvar, :bar)))
      expect(result).to eq("foo(bar)")
    end
  end
end

