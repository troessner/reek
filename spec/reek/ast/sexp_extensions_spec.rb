require_relative '../../spec_helper'
require_lib 'reek/ast/sexp_extensions'

RSpec.describe Reek::AST::SexpExtensions::DefNode do
  context 'with no parameters' do
    let(:node) { sexp(:def, :hello, sexp(:args)) }

    it 'has no arg names' do
      expect(node.arg_names).to eq []
    end

    it 'has no parameter names' do
      expect(node.parameter_names).to eq []
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'hello'
    end
  end

  context 'with 1 parameter' do
    let(:node) do
      sexp(:def, :hello,
           sexp(:args, sexp(:arg, :param)))
    end

    it 'has 1 arg name' do
      expect(node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'hello'
    end
  end

  context 'with a block parameter' do
    let(:node) do
      sexp(:def, :hello,
           sexp(:args,
                sexp(:arg, :param),
                sexp(:blockarg, :blk)))
    end

    it 'has 1 arg name' do
      expect(node.arg_names).to eq [:param]
    end

    it 'has 2 parameter names' do
      expect(node.parameter_names).to eq [:param, :blk]
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'hello'
    end
  end

  context 'with 1 defaulted parameter' do
    let(:node) do
      sexp(:def, :hello,
           sexp(:args,
                sexp(:optarg, :param, sexp(:array))))
    end

    it 'has 1 arg name' do
      expect(node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'hello'
    end
  end

  context 'with a body with 2 statements' do
    let(:node) do
      sexp(:def, :hello, sexp(:args),
           sexp(:begin,
                sexp(:first),
                sexp(:second)))
    end

    it 'has 2 body statements' do
      expect(node.body).to eq sexp(:begin, sexp(:first), sexp(:second))
    end

    it 'finds nodes in the body with #body_nodes' do
      expect(node.body_nodes([:first])).to eq [sexp(:first)]
    end
  end

  context 'with no body' do
    let(:node) { sexp(:def, :hello, sexp(:args), nil) }

    it 'has a body that is nil' do
      expect(node.body).to be_nil
    end

    it 'finds no nodes in the body' do
      expect(node.body_nodes([:foo])).to eq []
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::DefsNode do
  context 'with no parameters' do
    let(:node) { sexp(:defs, sexp(:lvar, :obj), :hello, sexp(:args)) }

    it 'has no arg names' do
      expect(node.arg_names).to eq []
    end

    it 'has no parameter names' do
      expect(node.parameter_names).to eq []
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with 1 parameter' do
    let(:node) do
      sexp(:defs, sexp(:lvar, :obj), :hello,
           sexp(:args, sexp(:arg, :param)))
    end

    it 'has 1 arg name' do
      expect(node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with a block' do
    let(:node) do
      sexp(:defs, sexp(:lvar, :obj), :hello,
           sexp(:args,
                sexp(:arg, :param),
                sexp(:blockarg, :blk)))
    end

    it 'has 1 arg name' do
      expect(node.arg_names).to eq [:param]
    end

    it 'has 2 parameter names' do
      expect(node.parameter_names).to eq [:param, :blk]
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with 1 defaulted parameter' do
    let(:node) do
      sexp(:defs, sexp(:lvar, :obj), :hello,
           sexp(:args,
                sexp(:optarg, :param, sexp(:array))))
    end

    it 'has 1 arg name' do
      expect(node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with a body with 2 statements' do
    let(:node) do
      sexp(:defs, sexp(:self), :hello, sexp(:args),
           sexp(:begin,
                sexp(:first),
                sexp(:second)))
    end

    it 'has 2 body statements' do
      expect(node.body).to eq sexp(:begin, sexp(:first), sexp(:second))
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::LvarNode do
  let(:node) { sexp(:lvar, :foo) }
  describe '#var_name' do
    it 'returns the lvar’s name' do
      expect(node.var_name).to eq(:foo)
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::SendNode do
  context 'with no parameters' do
    let(:node) { sexp(:send, nil, :hello) }

    it 'has no argument names' do
      expect(node.arg_names).to eq []
    end

    it 'is not considered to be a writable attr' do
      expect(sexp(:send, nil, :attr).attr_with_writable_flag?).to be_falsey
    end
  end

  context 'when it’s ‘new’ with no parameters and no receiver' do
    let(:bare_new) { sexp(:send, nil, :new) }

    it 'is not considered to be a module creation call' do
      expect(bare_new.module_creation_call?).to be_falsey
    end

    it 'is not considered to have a module creation receiver' do
      expect(bare_new.module_creation_receiver?).to be_falsey
    end

    it 'is considered to be an object creation call' do
      expect(bare_new.object_creation_call?).to be_truthy
    end
  end

  context 'with 1 literal parameter' do
    let(:node) { sexp(:send, nil, :hello, sexp(:lit, :param)) }

    it 'has 1 argument name' do
      expect(node.arg_names).to eq [:param]
    end
  end

  context 'with 2 literal parameters' do
    let(:node) { sexp(:send, nil, :hello, sexp(:lit, :x), sexp(:lit, :y)) }

    it 'has 2 argument names' do
      expect(node.arg_names).to eq [:x, :y]
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::BlockNode do
  context 'with no parameters' do
    let(:node) { sexp(:block, sexp(:send, nil, :map), sexp(:args), nil) }

    it 'has no parameter names' do
      expect(node.parameter_names).to eq []
    end

    it 'has a name' do
      expect(node.simple_name).to eq(:block)
    end
  end

  context 'with 1 parameter' do
    let(:node) { sexp(:block, sexp(:send, nil, :map), sexp(:args, :param), nil) }

    it 'has 1 parameter name' do
      expect(node.parameter_names).to eq [:param]
    end
  end

  context 'with 2 parameters' do
    let(:node) { sexp(:block, sexp(:send, nil, :map), sexp(:args, :x, :y), nil) }

    it 'has 2 parameter names' do
      expect(node.parameter_names).to eq [:x, :y]
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::ModuleNode do
  context 'with a simple name' do
    subject do
      mod = sexp(:module, :Fred, nil)
      mod
    end

    it 'has the correct #name' do
      expect(subject.name).to eq 'Fred'
    end

    it 'has the correct #simple_name' do
      expect(subject.simple_name).to eq 'Fred'
    end

    it 'has a simple full_name' do
      expect(subject.full_name('')).to eq 'Fred'
    end

    it 'has a fq full_name' do
      expect(subject.full_name('Blimey::O::Reilly')).to eq 'Blimey::O::Reilly::Fred'
    end
  end

  context 'with a scoped name' do
    subject do
      sexp(:module, sexp(:const, sexp(:const, nil, :Foo), :Bar), nil)
    end

    it 'has the correct #name' do
      expect(subject.name).to eq 'Foo::Bar'
    end

    it 'has the correct #simple_name' do
      expect(subject.simple_name).to eq 'Bar'
    end

    it 'has a simple full_name' do
      expect(subject.full_name('')).to eq 'Foo::Bar'
    end

    it 'has a fq full_name' do
      expect(subject.full_name('Blimey::O::Reilly')).to eq 'Blimey::O::Reilly::Foo::Bar'
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::CasgnNode do
  context 'with single assignment' do
    subject do
      sexp(:casgn, nil, :Foo)
    end

    it 'does not define a module' do
      expect(subject.defines_module?).to be_falsey
    end
  end

  context 'with implicit receiver to new' do
    it 'does not define a module' do
      exp = sexp(:casgn, nil, :Foo, sexp(:send, nil, :new))
      expect(exp.defines_module?).to be_falsey
    end
  end
end
