require_relative '../../spec_helper'
require 'stringio'
require_lib 'reek/source/source_code'

RSpec.describe Reek::Source::SourceCode do
  describe '#syntax_tree' do
    it 'associates comments with the AST' do
      source = "# this is\n# a comment\ndef foo; end"
      source_code = described_class.new(source: source, origin: '(string)')
      result = source_code.syntax_tree
      expect(result.leading_comment).to eq "# this is\n# a comment"
    end

    it 'cleanly processes empty source' do
      source_code = described_class.new(source: '', origin: '(string)')
      result = source_code.syntax_tree
      expect(result.type).to eq :empty
    end

    it 'cleanly processes empty source with comments' do
      source = "# this is\n# a comment\n"
      source_code = described_class.new(source: source, origin: '(string)')
      result = source_code.syntax_tree
      expect(result.type).to eq :empty
    end

    it 'does not crash with sequences incompatible with UTF-8' do
      source = '"\xFF"'
      source_code = described_class.new(source: source, origin: '(string)')
      result = source_code.syntax_tree
      expect(result.children.first).to eq "\xFF"
    end

    it 'returns a :lambda node for lambda expressions' do
      source = '->() { }'
      source_code = described_class.new(source: source, origin: '(string)')
      result = source_code.syntax_tree
      expect(result.children.first.type).to eq :lambda
    end

    context 'when the parser fails with a Parser::SyntaxError' do
      let(:src) { described_class.new(source: code) }
      let(:code) { '== Invalid Syntax ==' }

      it 'raises the error' do
        expect { src.syntax_tree }.to raise_error Parser::SyntaxError
      end
    end

    context 'when the parser fails with a generic error' do
      let(:code) { '' }
      let(:parser) { instance_double('Parser::Ruby25') }
      let(:src) { described_class.new(source: code, parser: parser) }
      let(:error_class) { RuntimeError }
      let(:error_message) { 'An error' }

      before do
        allow(parser).to receive(:parse_with_comments).and_raise(error_class, error_message)
      end

      it 'raises the error' do
        expect { src.syntax_tree }.to raise_error error_class, error_message
      end
    end
  end
end
