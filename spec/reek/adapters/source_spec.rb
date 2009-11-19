require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/adapters/source'

include Reek

describe Source do
  context 'when the parser fails' do
    it 'returns an empty syntax tree' do
      parser = mock('parser')
      parser.should_receive(:parse).and_raise(SyntaxError)
      src = Source.new('', '', parser)
      src.syntax_tree.should == s()
    end
  end
end
