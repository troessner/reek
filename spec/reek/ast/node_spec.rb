require_relative '../../spec_helper'
require_lib 'reek/ast/node'

RSpec.describe Reek::AST::Node do
  describe '#format_to_ruby' do
    it 'returns #to_s if location is not present' do
      ast = sexp(:self)
      expect(ast.format_to_ruby).to eq ast.to_s
    end

    it 'gives the right result for self' do
      ast = Reek::Source::SourceCode.from('self').syntax_tree
      expect(ast.format_to_ruby).to eq 'self'
    end

    it 'gives the right result for a simple expression' do
      ast = Reek::Source::SourceCode.from('foo').syntax_tree
      expect(ast.format_to_ruby).to eq 'foo'
    end

    it 'gives the right result for a more complex expression' do
      ast = Reek::Source::SourceCode.from('foo(bar)').syntax_tree
      result = ast.format_to_ruby
      expect(result).to eq 'foo(bar)'
    end

    it 'gives te right result for send with a receiver' do
      ast = Reek::Source::SourceCode.from('baz.foo(bar)').syntax_tree
      expect(ast.format_to_ruby).to eq 'baz.foo(bar)'
    end

    it 'gives the right result for if' do
      source = <<-SRC
        if foo
          bar
        else
          baz
          qux
        end
      SRC

      ast = Reek::Source::SourceCode.from(source).syntax_tree
      expect(ast.format_to_ruby).to eq 'if foo ... end'
    end

    it 'gives the right result for def with no body' do
      source = "def my_method\nend"
      ast = Reek::Source::SourceCode.from(source).syntax_tree
      expect(ast.format_to_ruby).to eq 'def my_method; end'
    end

    it 'gives the right result for ivar' do
      source = '@foo'
      ast = Reek::Source::SourceCode.from(source).syntax_tree
      expect(ast.format_to_ruby).to eq '@foo'
    end
  end

  context 'hash' do
    it 'hashes equal for equal sexps' do
      node1 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 4), :+, sexp(:send, nil, :fred)))
      node2 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 4), :+, sexp(:send, nil, :fred)))
      expect(node1.hash).to eq(node2.hash)
    end

    it 'hashes diferent for diferent sexps' do
      node1 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 4), :+, sexp(:send, nil, :fred)))
      node2 = sexp(:def, :jim, sexp(:args), sexp(:send, sexp(:int, 3), :+, sexp(:send, nil, :fred)))
      expect(node1.hash).not_to eq(node2.hash)
    end
  end

  describe '#length' do
    it 'counts itself as representing one statement' do
      expect(sexp(:foo).length).to eq 1
    end
  end

  describe '#line' do
    context 'source from file' do
      let(:file) { SAMPLES_PATH.join('smelly.rb') }
      let(:ast) { Reek::Source::SourceCode.from(file).syntax_tree }

      it 'returns the right line number' do
        expect(ast.line).to eq(2)
      end
    end

    context 'source from string' do
      let(:source) { File.read(SAMPLES_PATH.join('smelly.rb')) }
      let(:ast) { Reek::Source::SourceCode.from(source).syntax_tree }

      it 'returns the right line number' do
        expect(ast.line).to eq(2)
      end
    end
  end

  describe '#source' do
    context 'source from file' do
      let(:file) { SAMPLES_PATH.join('smelly.rb') }
      let(:ast) { Reek::Source::SourceCode.from(file).syntax_tree }

      it 'returns the file name' do
        expect(ast.source).to eq(SAMPLES_PATH.join('smelly.rb').to_s)
      end
    end

    context 'source from string' do
      let(:source) { File.read(SAMPLES_PATH.join('smelly.rb')) }
      let(:ast) { Reek::Source::SourceCode.from(source).syntax_tree }

      it 'returns "string"' do
        expect(ast.source).to eq('string')
      end
    end
  end
end
