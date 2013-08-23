require 'spec_helper'
require 'stringio'
require 'reek/source/source_code'

include Reek::Source

describe SourceCode do
  context 'when the parser fails' do
    before :each do
      @catcher = StringIO.new
      @old_err_io = (SourceCode.err_io = @catcher)
      parser = double('parser')
      @error_message = 'Error message'
      parser.should_receive(:parse).and_raise(SyntaxError.new(@error_message))
      @source_name = 'Test source'
      @src = SourceCode.new('', @source_name, parser)
    end
    it 'raises a SyntaxError' do
      @src.syntax_tree
    end
    it 'returns an empty syntax tree' do
      @src.syntax_tree.should == s()
    end
    it 'records the syntax error' do
      @src.syntax_tree
      @catcher.string.should match(SyntaxError.name)
    end
    it 'records the source name' do
      @src.syntax_tree
      @catcher.string.should match(@source_name)
    end
    it 'records the error message' do
      @src.syntax_tree
      @catcher.string.should match(@error_message)
    end
    after :each do
      SourceCode.err_io = @old_err_io
    end
  end
end
