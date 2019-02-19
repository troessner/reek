require_relative '../../spec_helper'
require_lib 'reek/ast/node'

RSpec.describe Reek::AST::Node do
  describe '#each_node' do
    context 'with an empty module' do
      let(:ast) do
        src = 'module Emptiness; end'
        Reek::Source::SourceCode.from(src).syntax_tree
      end

      it 'yields no calls' do
        ast.each_node(:send, []) { |exp| raise "#{exp} yielded by empty module!" }
      end

      it 'yields one module' do
        mods = 0
        ast.each_node(:module, []) { |_exp| mods += 1 }
        expect(mods).to eq(1)
      end

      it "yields the module's full AST" do
        ast.each_node(:module, []) do |exp|
          expect(exp).to eq(sexp(:module, sexp(:const, nil, :Emptiness), nil))
        end
      end

      it 'returns an enumerator when no block is passed' do
        expect(ast.each_node(:if)).to be_instance_of Enumerator
      end
    end

    context 'with a nested element' do
      let(:ast) do
        src = "module Loneliness; def calloo; puts('hello') end; end"
        Reek::Source::SourceCode.from(src).syntax_tree
      end

      it 'yields no ifs' do
        ast.each_node(:if) { |exp| raise "#{exp} yielded by empty module!" }
      end

      it 'yields one module' do
        expect(ast.each_node(:module).to_a.length).to eq(1)
      end

      it "yields the module's full AST" do
        ast.each_node(:module) do |exp|
          expect(exp).to eq sexp(:module,
                                 sexp(:const, nil, :Loneliness),
                                 sexp(:def, :calloo,
                                      sexp(:args),
                                      sexp(:send, nil, :puts, sexp(:str, 'hello'))))
        end
      end

      it 'yields one method' do
        expect(ast.each_node(:def).to_a.length).to eq(1)
      end

      it "yields the method's full AST" do
        ast.each_node(:def, []) { |exp| expect(exp.children.first).to eq(:calloo) }
      end

      it 'ignores the call inside the method if the traversal is pruned' do
        expect(ast.each_node(:send, [:def]).to_a).to be_empty
      end
    end

    it 'finds 3 ifs in a class' do
      src = <<-RUBY
        class Scrunch
          def first
            return @field == :sym ? 0 : 3;
          end
          def second
            if @field == :sym
              @other += " quarts"
            end
          end
          def third
            raise 'flu!' unless @field == :sym
          end
        end
      RUBY
      ast = Reek::Source::SourceCode.from(src).syntax_tree
      expect(ast.each_node(:if).to_a.length).to eq(3)
    end
  end

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

  describe '#hash' do
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
    context 'with source from a file' do
      let(:file) { SMELLY_FILE }
      let(:ast) { Reek::Source::SourceCode.from(file).syntax_tree }

      it 'returns the right line number' do
        expect(ast.line).to eq(2)
      end
    end

    context 'with source from a string' do
      let(:source) { File.read(SMELLY_FILE) }
      let(:ast) { Reek::Source::SourceCode.from(source).syntax_tree }

      it 'returns the right line number' do
        expect(ast.line).to eq(2)
      end
    end
  end

  describe '#source' do
    context 'with source from a file' do
      let(:file) { SMELLY_FILE }
      let(:ast) { Reek::Source::SourceCode.from(file).syntax_tree }

      it 'returns the file name' do
        expect(ast.source).to eq(SMELLY_FILE.to_s)
      end
    end

    context 'with source from a string' do
      let(:source) { File.read SMELLY_FILE }
      let(:ast) { Reek::Source::SourceCode.from(source).syntax_tree }

      it 'returns "string"' do
        expect(ast.source).to eq('string')
      end
    end
  end

  describe '#name' do
    it 'returns #to_s if no override is present' do
      ast = sexp(:foo)
      expect(ast.name).to eq ast.to_s
    end
  end
end
