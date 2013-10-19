require 'spec_helper'
require 'reek/source/tree_dresser'

include Reek::Source

describe TreeDresser do
  let(:ifnode) { Sexp.new(:if) }
  let(:callnode) { Sexp.new(:call) }
  let(:dresser) { TreeDresser.new }

  it 'dresses :if sexp with IfNode' do
    dresser.dress(ifnode).should be_a Reek::Source::SexpExtensions::IfNode
  end

  it 'dresses :call sexp with CallNode' do
    dresser.dress(callnode).should be_a Reek::Source::SexpExtensions::CallNode
  end
end
