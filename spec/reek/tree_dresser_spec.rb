require_relative '../spec_helper'
require_relative '../../lib/reek/tree_dresser'

RSpec.describe Reek::TreeDresser do
  let(:ifnode) { ::Parser::AST::Node.new(:if) }
  let(:sendnode) { ::Parser::AST::Node.new(:send) }
  let(:dresser) { described_class.new }

  it 'dresses :if sexp with IfNode' do
    expect(dresser.dress(ifnode, {})).to be_a Reek::AST::SexpExtensions::IfNode
  end

  it 'dresses :send sexp with SendNode' do
    expect(dresser.dress(sendnode, {})).to be_a Reek::AST::SexpExtensions::SendNode
  end
end
