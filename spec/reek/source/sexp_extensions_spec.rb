require 'spec_helper'
require 'reek/source/sexp_extensions'

include Reek::Source

describe SexpExtensions::DefNode do
  context 'with no parameters' do
    before :each do
      @node = s(:def, :hello, s(:args))
    end

    it 'has no arg names' do
      expect(@node.arg_names).to eq []
    end

    it 'has no parameter names' do
      expect(@node.parameter_names).to eq []
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'hello'
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:def, :hello,
                s(:args, s(:arg, :param)))
    end

    it 'has 1 arg name' do
      expect(@node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'hello'
    end
  end

  context 'with a block parameter' do
    before :each do
      @node = s(:def, :hello,
                s(:args,
                  s(:arg, :param),
                  s(:blockarg, :blk)))
    end

    it 'has 1 arg name' do
      expect(@node.arg_names).to eq [:param]
    end

    it 'has 2 parameter names' do
      expect(@node.parameter_names).to eq [:param, :blk]
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'hello'
    end
  end

  context 'with 1 defaulted parameter' do
    before :each do
      @node = s(:def, :hello,
                s(:args,
                  s(:optarg, :param, s(:array))))
    end

    it 'has 1 arg name' do
      expect(@node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'hello'
    end
  end

  context 'with a body with 2 statements' do
    before :each do
      @node = s(:def, :hello, s(:args),
                s(:begin,
                  s(:first),
                  s(:second)))
    end

    it 'has 2 body statements' do
      expect(@node.body).to eq s(:begin, s(:first), s(:second))
    end

    it 'has a body extended with SexpNode' do
      b = @node.body
      expect(b.class.included_modules.first).to eq SexpNode
    end

    it 'finds nodes in the body with #body_nodes' do
      expect(@node.body_nodes([:first])).to eq [s(:first)]
    end
  end

  context 'with no body' do
    before :each do
      @node = s(:def, :hello, s(:args), nil)
    end

    it 'has a body that is nil' do
      expect(@node.body).to be_nil
    end

    it 'finds no nodes in the body' do
      expect(@node.body_nodes([:foo])).to eq []
    end
  end
end

describe SexpExtensions::DefsNode do
  context 'with no parameters' do
    before :each do
      @node = s(:defs, s(:lvar, :obj), :hello, s(:args))
    end

    it 'has no arg names' do
      expect(@node.arg_names).to eq []
    end

    it 'has no parameter names' do
      expect(@node.parameter_names).to eq []
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:defs, s(:lvar, :obj), :hello,
                s(:args, s(:arg, :param)))
    end

    it 'has 1 arg name' do
      expect(@node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with a block' do
    before :each do
      @node = s(:defs, s(:lvar, :obj), :hello,
                s(:args,
                  s(:arg, :param),
                  s(:blockarg, :blk)))
    end

    it 'has 1 arg name' do
      expect(@node.arg_names).to eq [:param]
    end

    it 'has 2 parameter names' do
      expect(@node.parameter_names).to eq [:param, :blk]
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with 1 defaulted parameter' do
    before :each do
      @node = s(:defs, s(:lvar, :obj), :hello,
                s(:args,
                  s(:optarg, :param, s(:array))))
    end

    it 'has 1 arg name' do
      expect(@node.arg_names).to eq [:param]
    end

    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq [:param]
    end

    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq 'Fred#obj.hello'
    end

    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq 'obj.hello'
    end
  end

  context 'with a body with 2 statements' do
    before :each do
      @node = s(:defs, s(:self), :hello, s(:args),
                s(:begin,
                  s(:first),
                  s(:second)))
    end

    it 'has 2 body statements' do
      expect(@node.body).to eq s(:begin, s(:first), s(:second))
    end

    it 'has a body extended with SexpNode' do
      b = @node.body
      expect(b.class.included_modules.first).to eq SexpNode
    end
  end
end

describe SexpExtensions::SendNode do
  context 'with no parameters' do
    before :each do
      @node = s(:send, nil, :hello)
    end

    it 'has no argument names' do
      expect(@node.arg_names).to eq []
    end
  end

  context 'with 1 literal parameter' do
    before :each do
      @node = s(:send, nil, :hello, s(:lit, :param))
    end

    it 'has 1 argument name' do
      expect(@node.arg_names).to eq [:param]
    end
  end

  context 'with 2 literal parameters' do
    before :each do
      @node = s(:send, nil, :hello, s(:lit, :x), s(:lit, :y))
    end

    it 'has 2 argument names' do
      expect(@node.arg_names).to eq [:x, :y]
    end
  end
end

describe SexpExtensions::BlockNode do
  context 'with no parameters' do
    before :each do
      @node = s(:block, s(:send, nil, :map), s(:args), nil)
    end

    it 'has no parameter names' do
      expect(@node.parameter_names).to eq []
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:block, s(:send, nil, :map), s(:args, :param), nil)
    end

    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq [:param]
    end
  end

  context 'with 2 parameters' do
    before :each do
      @node = s(:block, s(:send, nil, :map), s(:args, :x, :y), nil)
    end

    it 'has 2 parameter names' do
      expect(@node.parameter_names).to eq [:x, :y]
    end
  end
end

describe SexpExtensions::ModuleNode do
  context 'with a simple name' do
    subject do
      mod = ast(:module, :Fred, nil)
      mod
    end

    it 'has the correct #name' do
      expect(subject.name).to eq :Fred
    end

    it 'has the correct #simple_name' do
      expect(subject.simple_name).to eq :Fred
    end

    it 'has the correct #text_name' do
      expect(subject.text_name).to eq 'Fred'
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
      s(:module, s(:const, s(:const, nil, :Foo), :Bar), nil)
    end

    it 'has the correct #name' do
      expect(subject.name).to eq s(:const, s(:const, nil, :Foo), :Bar)
    end

    it 'has the correct #simple_name' do
      expect(subject.simple_name).to eq :Bar
    end

    it 'has the correct #text_name' do
      expect(subject.text_name).to eq 'Foo::Bar'
    end

    it 'has a simple full_name' do
      expect(subject.full_name('')).to eq 'Foo::Bar'
    end

    it 'has a fq full_name' do
      expect(subject.full_name('Blimey::O::Reilly')).to eq 'Blimey::O::Reilly::Foo::Bar'
    end
  end
end
