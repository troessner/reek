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

RSpec.describe Reek::AST::SexpExtensions::CSendNode do
  let(:node) { Reek::Source::SourceCode.from('1&.foo(true)').syntax_tree }

  it 'has a class including SendNode' do
    expect(node.class.included_modules).to include(Reek::AST::SexpExtensions::SendNode)
  end

  it 'has a receiver' do
    expect(node.receiver).to eq(sexp(:int, 1))
  end

  it 'has a name' do
    expect(node.name).to eq(:foo)
  end

  it 'has arguments' do
    expect(node.args).to eq([sexp(:true)])
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

RSpec.describe Reek::AST::SexpExtensions::ConstNode do
  describe '#name' do
    it 'returns the fully qualified name' do
      node = sexp(:const, sexp(:const, sexp(:cbase), :Parser), :AST)

      expect(node.name).to eq "#{sexp(:const, sexp(:cbase), :Parser)}::AST"
    end

    it 'returns only the name in case of no namespace' do
      node = sexp(:const, nil, :AST)

      expect(node.name).to eq 'AST'
    end
  end

  describe '#simple_name' do
    it 'returns the name' do
      node = sexp(:const, sexp(:const, nil, :Rake), :TaskLib)

      expect(node.simple_name).to eq :TaskLib
    end
  end

  describe '#namespace' do
    it 'returns the namespace' do
      node = sexp(:const, :Parser, :AST)

      expect(node.namespace).to eq :Parser
    end

    it 'returns nil in case of no namespace' do
      node = sexp(:const, nil, :AST)

      expect(node.namespace).to be_nil
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

  context 'when it’s ‘new’ with a complex receiver' do
    let(:node) { Reek::Source::SourceCode.from('(foo ? bar : baz).new').syntax_tree }

    it 'is not considered to be a module creation call' do
      expect(node.module_creation_call?).to be_falsey
    end

    it 'is not considered to have a module creation receiver' do
      expect(node.module_creation_receiver?).to be_falsey
    end

    it 'is considered to be an object creation call' do
      expect(node.object_creation_call?).to be_truthy
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

RSpec.describe Reek::AST::SexpExtensions::LambdaNode do
  let(:node) { sexp(:lambda) }

  context '#name' do
    it 'returns :lambda' do
      expect(node.name).to eq 'lambda'
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::ModuleNode do
  context 'with a simple name' do
    let(:exp) do
      Reek::Source::SourceCode.from('module Fred; end').syntax_tree
    end

    it 'has the correct #name' do
      expect(exp.name).to eq 'Fred'
    end

    it 'has the correct #simple_name' do
      expect(exp.simple_name).to eq 'Fred'
    end

    it 'has a simple full_name' do
      expect(exp.full_name('')).to eq 'Fred'
    end

    it 'has a fq full_name' do
      expect(exp.full_name('Blimey::O::Reilly')).to eq 'Blimey::O::Reilly::Fred'
    end
  end

  context 'with a scoped name' do
    let(:exp) do
      Reek::Source::SourceCode.from('module Foo::Bar; end').syntax_tree
    end

    it 'has the correct #name' do
      expect(exp.name).to eq 'Foo::Bar'
    end

    it 'has the correct #simple_name' do
      expect(exp.simple_name).to eq 'Bar'
    end

    it 'has a simple full_name' do
      expect(exp.full_name('')).to eq 'Foo::Bar'
    end

    it 'has a fully qualified full_name' do
      expect(exp.full_name('Blimey::O::Reilly')).to eq 'Blimey::O::Reilly::Foo::Bar'
    end
  end

  context 'with a name scoped in a namespace that is not a constant' do
    let(:exp) do
      Reek::Source::SourceCode.from('module foo::Bar; end').syntax_tree
    end

    it 'has the correct #name' do
      expect(exp.name).to eq 'foo::Bar'
    end

    it 'has the correct #simple_name' do
      expect(exp.simple_name).to eq 'Bar'
    end
  end
end

RSpec.describe Reek::AST::SexpExtensions::CasgnNode do
  describe '#defines_module?' do
    context 'with single assignment' do
      it 'does not define a module' do
        exp = sexp(:casgn, nil, :Foo)
        expect(exp.defines_module?).to be_falsey
      end
    end

    context 'with implicit receiver to new' do
      it 'does not define a module' do
        exp = sexp(:casgn, nil, :Foo, sexp(:send, nil, :new))
        expect(exp.defines_module?).to be_falsey
      end
    end

    context 'with implicit receiver to new' do
      it 'does not define a module' do
        exp = Reek::Source::SourceCode.from('Foo = Class.new(Bar)').syntax_tree

        expect(exp.defines_module?).to be_truthy
      end
    end

    context 'when assigning a lambda to a constant' do
      it 'does not define a module' do
        exp = Reek::Source::SourceCode.from('C = ->{}').syntax_tree

        expect(exp.defines_module?).to be_falsey
      end
    end

    context 'when assigning a string to a constant' do
      it 'does not define a module' do
        exp = Reek::Source::SourceCode.from('C = "hello"').syntax_tree

        expect(exp.defines_module?).to be_falsey
      end
    end
  end

  describe '#superclass' do
    it 'returns the superclass from the class definition' do
      exp = Reek::Source::SourceCode.from('Foo = Class.new(Bar)').syntax_tree

      expect(exp.superclass).to eq sexp(:const, nil, :Bar)
    end

    it 'returns nil in case of no class definition' do
      exp = Reek::Source::SourceCode.from('Foo = 23').syntax_tree

      expect(exp.superclass).to be_nil
    end

    it 'returns nil in case of no superclass' do
      exp = Reek::Source::SourceCode.from('Foo = Class.new').syntax_tree

      expect(exp.superclass).to be_nil
    end

    it 'returns nothing for a class definition using Struct.new' do
      exp = Reek::Source::SourceCode.from('Foo = Struct.new("Bar")').syntax_tree

      expect(exp.superclass).to be_nil
    end

    it 'returns nothing for a constant assigned with a bare method call' do
      exp = Reek::Source::SourceCode.from('Foo = foo("Bar")').syntax_tree

      expect(exp.superclass).to be_nil
    end
  end
end
