#require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'stringio'
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'adapters', 'source')

include Reek

describe Source do
  context 'when the parser fails' do
    before :each do
      @catcher = StringIO.new
      @old_err_io = (Source.err_io = @catcher)
      parser = mock('parser')
      @error_message = 'Error message'
      parser.should_receive(:parse).and_raise(SyntaxError.new(@error_message))
      @source_name = 'Test source'
      @src = Source.new('', @source_name, parser)
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
      Source.err_io = @old_err_io
    end
  end
end
