require_relative '../../spec_helper'
require_lib 'reek/context/code_context'
require_lib 'reek/context/ghost_context'

RSpec.describe Reek::Context::GhostContext do
  let(:exp) { instance_double('Reek::AST::Node') }
  let(:parent) { Reek::Context::CodeContext.new(exp) }

  describe '#register_with_parent' do
    it 'does not append itself to its parent' do
      ghost = described_class.new(nil)
      ghost.register_with_parent(parent)
      expect(parent.children).not_to include ghost
    end
  end

  describe '#append_child_context' do
    let(:ghost) { described_class.new(nil) }

    before do
      ghost.register_with_parent(parent)
    end

    it 'appends the child to the grandparent context' do
      child = Reek::Context::CodeContext.new(sexp(:foo))
      child.register_with_parent(ghost)

      expect(parent.children).to include child
    end

    it "sets the child's parent to the grandparent context" do
      child = Reek::Context::CodeContext.new(sexp(:foo))
      child.register_with_parent(ghost)

      expect(child.parent).to eq parent
    end

    it 'appends the child to the list of children' do
      child = Reek::Context::CodeContext.new(sexp(:foo))
      child.register_with_parent(ghost)

      expect(ghost.children).to include child
    end

    context 'if the grandparent is also a ghost' do
      let(:child_ghost) { described_class.new(nil) }

      before do
        child_ghost.register_with_parent(ghost)
      end

      it 'sets the childs parent to its remote ancestor' do
        child = Reek::Context::CodeContext.new(sexp(:foo))
        child.register_with_parent(child_ghost)

        expect(child.parent).to eq parent
      end
    end
  end
end
