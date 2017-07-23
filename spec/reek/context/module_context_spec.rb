require_relative '../../spec_helper'
require_lib 'reek/context/module_context'
require_lib 'reek/context/root_context'

RSpec.describe Reek::Context::ModuleContext do
  it 'reports module name for smell in method' do
    expect('
      module Fred
        def simple(x) x + 1; end
      end
    ').to reek_of(:UncommunicativeParameterName, name: 'x', context: 'Fred#simple')
  end

  it 'does not report module with empty class' do
    expect('
      # module for test
      module Fred
        # module for test
        class Jim; end; end').not_to reek
  end

  it 'recognises global constant' do
    expect('
      # module for test
      module ::Global
        # module for test
        class Inside; end; end').not_to reek
  end

  describe '#track_visibility' do
    let(:main_exp) { instance_double('Reek::AST::Node') }
    let(:first_def) { instance_double('Reek::AST::SexpExtensions::DefNode', name: :foo) }
    let(:second_def) { instance_double('Reek::AST::SexpExtensions::DefNode') }

    let(:context) { described_class.new(main_exp) }
    let(:first_child) { Reek::Context::MethodContext.new(first_def, main_exp) }
    let(:second_child) { Reek::Context::MethodContext.new(second_def, main_exp) }

    it 'sets visibility on subsequent child contexts' do
      context.append_child_context first_child
      context.track_visibility :private, []
      context.append_child_context second_child
      expect(first_child.visibility).to eq :public
      expect(second_child.visibility).to eq :private
    end

    it 'sets visibility on specifically mentioned child contexts' do
      context.append_child_context first_child
      context.track_visibility :private, [first_child.name]
      context.append_child_context second_child
      expect(first_child.visibility).to eq :private
      expect(second_child.visibility).to eq :public
    end
  end
end
