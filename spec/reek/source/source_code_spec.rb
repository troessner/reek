require_relative '../../spec_helper'
require 'stringio'
require_lib 'reek/source/source_code'

RSpec.describe Reek::Source::SourceCode do
  describe '#syntax_tree' do
    it 'associates comments with the AST' do
      source = "# this is\n# a comment\ndef foo; end"
      source_code = described_class.new(code: source, origin: '(string)')
      result = source_code.syntax_tree
      expect(result.leading_comment).to eq "# this is\n# a comment"
    end

    it 'cleanly processes empty source' do
      source_code = described_class.new(code: '', origin: '(string)')
      result = source_code.syntax_tree
      expect(result).to be_nil
    end

    it 'cleanly processes empty source with comments' do
      source = "# this is\n# a comment\n"
      source_code = described_class.new(code: source, origin: '(string)')
      result = source_code.syntax_tree
      expect(result).to be_nil
    end

    it 'does not crash with sequences incompatible with UTF-8' do
      source = '"\xFF"'
      source_code = described_class.new(code: source, origin: '(string)')
      result = source_code.syntax_tree
      expect(result.children.first).to eq "\xFF"
    end
  end

  context 'when the parser fails' do
    let(:source_name) { 'Test source' }
    let(:error_message) { 'Error message' }
    let(:parser) { instance_double('Parser::Ruby24') }
    let(:src) { described_class.new(code: '', origin: source_name, parser: parser) }

    shared_examples_for 'handling and recording the error' do
      it 'raises an informative error' do
        expect { src.syntax_tree }.
          to raise_error(/#{source_name}: #{error_class.name}: #{error_message}/)
      end
    end

    context 'with a Parser::SyntaxError' do
      let(:error_class) { Parser::SyntaxError }
      let(:diagnostic) { instance_double('Parser::Diagnostic', message: error_message) }

      before do
        allow(parser).to receive(:parse_with_comments).
          and_raise error_class.new(diagnostic)
      end

      it_behaves_like 'handling and recording the error'
    end

    context 'with a Racc::ParseError' do
      let(:error_class) { Racc::ParseError }

      before do
        allow(parser).to receive(:parse_with_comments).
          and_raise(error_class.new(error_message))
      end

      it_behaves_like 'handling and recording the error'
    end

    context 'with a generic error' do
      let(:error_class) { RuntimeError }

      before do
        allow(parser).to receive(:parse_with_comments).
          and_raise(error_class.new(error_message))
      end

      it 'raises the error' do
        expect { src.syntax_tree }.to raise_error error_class
      end
    end
  end
end
