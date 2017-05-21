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
    let(:src) { described_class.new(code: code, origin: source_name, **parser) }

    context 'with a Parser::SyntaxError' do
      let(:code) { '== Invalid Syntax ==' }
      let(:parser) { {} }

      it 'adds a diagnostic' do
        expect(src.diagnostics.size).to eq 2
      end
    end

    context 'with a generic error' do
      let(:code) { '' }
      let(:error_class) { RuntimeError }
      let(:error_message) { 'An error' }
      let(:parser) do
        parser = instance_double('Parser::Ruby24')
        allow(parser).to receive(:parse_with_comments).and_raise(error_class, error_message)
        {
          parser: parser
        }
      end

      it 'raises the error' do
        expect { src }.to raise_error error_class, error_message
      end
    end
  end
end
