require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/tree_dresser'

RSpec.describe Reek::Core::TreeDresser do
  let(:ifnode) { Parser::AST::Node.new(:if) }
  let(:sendnode) { Parser::AST::Node.new(:send) }
  let(:dresser) { described_class.new }

  it 'dresses :if sexp with IfNode' do
    expect(dresser.dress(ifnode, {})).to be_a Reek::Sexp::SexpExtensions::IfNode
  end

  it 'dresses :send sexp with SendNode' do
    expect(dresser.dress(sendnode, {})).to be_a Reek::Sexp::SexpExtensions::SendNode
  end
end
