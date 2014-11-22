require 'spec_helper'
require 'reek/source/tree_dresser'

include Reek::Source

describe TreeDresser do
  let(:ifnode) { Parser::AST::Node.new(:if) }
  let(:sendnode) { Parser::AST::Node.new(:send) }
  let(:dresser) { TreeDresser.new }

  it 'dresses :if sexp with IfNode' do
    expect(dresser.dress(ifnode, {})).to be_a Reek::Source::SexpExtensions::IfNode
  end

  it 'dresses :send sexp with SendNode' do
    expect(dresser.dress(sendnode, {})).to be_a Reek::Source::SexpExtensions::SendNode
  end
end
