require_lib 'reek/cli/silencer'
Reek::CLI::Silencer.silently do
  require 'parser/ruby22'
end

require_relative '../spec_helper'
require_lib 'reek/tree_dresser'

RSpec.describe Reek::TreeDresser do
  let(:dresser) { described_class.new }
  let(:sexp) do
    Parser::Ruby22.parse('class Klazz; def meth(argument); argument.call_me; end; end')
  end
  let(:dressed_ast) do
    # The dressed AST looks like this:
    #   (class
    #     (const nil :Klazz) nil
    #     (def :meth
    #       (args
    #         (arg :argument))
    #       (send
    #         (lvar :argument) :call_me)))
    dresser.dress(sexp, {})
  end
  let(:const_node) { dressed_ast.children.first }
  let(:def_node) { dressed_ast.children.last }
  let(:args_node) { def_node.children[1] }
  let(:send_node) { def_node.children[2] }

  context 'dresses the given sexp' do
    it 'dresses `const` nodes properly' do
      expect(const_node).to be_a Reek::AST::SexpExtensions::ConstNode
    end

    it 'dresses `def` nodes properly' do
      expect(def_node).
        to be_a(Reek::AST::SexpExtensions::DefNode).
        and be_a(Reek::AST::SexpExtensions::MethodNodeBase)
    end

    it 'dresses `args` nodes properly' do
      expect(args_node).
        to be_a(Reek::AST::SexpExtensions::ArgsNode).
        and be_a(Reek::AST::SexpExtensions::NestedAssignables)
    end

    it 'dresses `send` nodes properly' do
      expect(send_node).to be_a Reek::AST::SexpExtensions::SendNode
    end
  end
end
