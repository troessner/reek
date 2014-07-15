require 'spec_helper'
require 'stringio'
require 'reek/source/source_code'

include Reek::Source

describe SourceCode do
  context 'when the parser fails' do
    let(:source_name) { 'Test source' }
    let(:error_message) { 'Error message' }
    let(:parser) { double('parser') }
    let(:src) { SourceCode.new('', source_name, parser) }

    before :each do
      @catcher = StringIO.new
      @old_err_io = (SourceCode.err_io = @catcher)
    end

    shared_examples_for "handling and recording the error" do
      it 'does not raise an error' do
        src.syntax_tree
      end

      it 'returns an empty syntax tree' do
        expect(src.syntax_tree).to eq(s())
      end

      it 'records the syntax error' do
        src.syntax_tree
        expect(@catcher.string).to match(error_class.name)
      end

      it 'records the source name' do
        src.syntax_tree
        expect(@catcher.string).to match(source_name)
      end

      it 'records the error message' do
        src.syntax_tree
        expect(@catcher.string).to match(error_message)
      end
    end

    context "with a RubyParser::SyntaxError" do
      let(:error_class) { RubyParser::SyntaxError }

      before do
        allow(parser).to receive(:parse).and_raise(error_class.new(error_message))
      end

      it_should_behave_like "handling and recording the error"
    end

    context "with a Racc::ParseError" do
      let(:error_class) { Racc::ParseError }

      before do
        allow(parser).to receive(:parse).and_raise(error_class.new(error_message))
      end

      it_should_behave_like "handling and recording the error"
    end

    context "with a generic error" do
      let(:error_class) { RuntimeError }

      before do
        allow(parser).to receive(:parse).and_raise(error_class.new(error_message))
      end

      it 'raises the error' do
        expect { src.syntax_tree }.to raise_error
      end
    end

    after :each do
      SourceCode.err_io = @old_err_io
    end
  end
end
