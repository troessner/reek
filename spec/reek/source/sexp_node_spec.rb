require 'spec_helper'
require 'reek/source/sexp_node'

include Reek::Source

describe SexpNode do
  context 'format' do
    it 'formats self' do
      @node = s(:self)
      @node.extend(SexpNode)
      @node.format_ruby.should == 'self'
    end
  end

  context 'hash' do
    it 'hashes equal for equal sexps' do
      node1 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 4), :fred))
      node2 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 4), :fred))
      node1.hash.should == node2.hash
    end
    it 'hashes diferent for diferent sexps' do
      node1 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 4), :fred))
      node2 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 3), :fred))
      node1.hash.should_not == node2.hash
    end
  end
end
