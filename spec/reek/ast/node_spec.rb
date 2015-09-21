require_relative '../../spec_helper'
require_lib 'reek/ast/node'

RSpec.describe Reek::AST::Node do
  context 'format' do
    it 'formats self' do
      expect(sexp(:self).format_to_ruby).to eq('self')
    end
  end

  context 'hash' do
    it 'hashes equal for equal sexps' do
      node1 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 4), :+, sexp(:send, nil, :fred)))
      node2 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 4), :+, sexp(:send, nil, :fred)))
      expect(node1.hash).to eq(node2.hash)
    end

    it 'hashes diferent for diferent sexps' do
      node1 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 4), :+, sexp(:send, nil, :fred)))
      node2 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 3), :+, sexp(:send, nil, :fred)))
      expect(node1.hash).not_to eq(node2.hash)
    end
  end
end
