require_relative '../../spec_helper'
require_relative '../../../lib/reek/sexp/sexp_node'

RSpec.describe Reek::Sexp::SexpNode do
  context 'format' do
    it 'formats self' do
      @node = s(:self)
      expect(@node.format_to_ruby).to eq('self')
    end
  end

  context 'hash' do
    it 'hashes equal for equal sexps' do
      node1 = s(:def, :jim, s(:args), s(:send, s(:int, 4), :+, s(:send, nil, :fred)))
      node2 = s(:def, :jim, s(:args), s(:send, s(:int, 4), :+, s(:send, nil, :fred)))
      expect(node1.hash).to eq(node2.hash)
    end

    it 'hashes diferent for diferent sexps' do
      node1 = s(:def, :jim, s(:args), s(:send, s(:int, 4), :+, s(:send, nil, :fred)))
      node2 = s(:def, :jim, s(:args), s(:send, s(:int, 3), :+, s(:send, nil, :fred)))
      expect(node1.hash).not_to eq(node2.hash)
    end
  end
end
