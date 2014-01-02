require 'spec_helper'
require 'reek/source/sexp_extensions'

include Reek::Source

describe SexpExtensions::DefnNode do
  context 'with no parameters' do
    before :each do
      @node = s(:defn, :hello, s(:args))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has no arg names' do
      @node.arg_names.should == s()
    end
    it 'has no parameter names' do
      @node.parameter_names.should == s()
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'hello'
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:defn, :hello, s(:args, :param))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has 1 arg name' do
      @node.arg_names.should == s(:param)
    end
    it 'has 1 parameter name' do
      @node.parameter_names.should == s(:param)
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'hello'
    end
  end

  context 'with a block' do
    before :each do
      @node = s(:defn, :hello, s(:args, :param, :"&blk"))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has 1 arg name' do
      @node.arg_names.should == s(:param)
    end
    it 'has 2 parameter names' do
      @node.parameter_names.should == s(:param, :"&blk")
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'hello'
    end
  end

  context 'with 1 defaulted parameter' do
    before :each do
      @node = s(:defn, :hello, s(:args, s(:lasgn, :param, s(:array))))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has 1 arg name' do
      @node.arg_names.should == s(:param)
    end
    it 'has 1 parameter name' do
      @node.parameter_names.should == s(:param)
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'hello'
    end
  end

  context 'with a body with 2 statements' do
    before :each do
      @node = s(:defn, :hello, s(:args), s(:first), s(:second))
      @node.extend(SexpExtensions::DefnNode)
    end

    it 'has 2 body statements' do
      @node.body.should == s(s(:first), s(:second))
    end

    it 'has a body extended with SexpNode' do
      b = @node.body
      (class << b; self; end).included_modules.first.should == SexpNode
    end
  end
end

describe SexpExtensions::DefsNode do
  context 'with no parameters' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has no arg names' do
      @node.arg_names.should == s()
    end
    it 'has no parameter names' do
      @node.parameter_names.should == s()
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#obj.hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'obj.hello'
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args, :param))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has 1 arg name' do
      @node.arg_names.should == s(:param)
    end
    it 'has 1 parameter name' do
      @node.parameter_names.should == s(:param)
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#obj.hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'obj.hello'
    end
  end

  context 'with a block' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args, :param, :"&blk"))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has 1 arg name' do
      @node.arg_names.should == s(:param)
    end
    it 'has 2 parameter names' do
      @node.parameter_names.should == s(:param, :"&blk")
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#obj.hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'obj.hello'
    end
  end

  context 'with 1 defaulted parameter' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args, s(:lasgn, :param, s(:array))))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has 1 arg name' do
      @node.arg_names.should == s(:param)
    end
    it 'has 1 parameter name' do
      @node.parameter_names.should == s(:param)
    end
    it 'includes outer scope in its full name' do
      @node.full_name('Fred').should == 'Fred#obj.hello'
    end
    it 'includes no marker in its full name with empty outer scope' do
      @node.full_name('').should == 'obj.hello'
    end
  end

  context 'with a body with 2 statements' do
    before :each do
      @node = s(:defs, s(:self), :hello, s(:args), s(:first), s(:second))
      @node.extend(SexpExtensions::DefsNode)
    end

    it 'has 2 body statements' do
      @node.body.should == s(s(:first), s(:second))
    end

    it 'has a body extended with SexpNode' do
      b = @node.body
      (class << b; self; end).included_modules.first.should == SexpNode
    end
  end
end

describe SexpExtensions::CallNode do
  context 'with no parameters' do
    before :each do
      @node = s(:call, nil, :hello)
      @node.extend(SexpExtensions::CallNode)
    end
    it 'has no parameter names' do
      @node.parameter_names.should == nil
    end
  end

  context 'with 1 literal parameter' do
    before :each do
      @node = s(:call, nil, :hello, s(:lit, :param))
      @node.extend(SexpExtensions::CallNode)
    end
    it 'has 1 argument name' do
      @node.arg_names.should == [:param]
    end
  end

  context 'with 2 literal parameters' do
    before :each do
      @node = s(:call, nil, :hello, s(:lit, :x), s(:lit, :y))
      @node.extend(SexpExtensions::CallNode)
    end
    it 'has 2 argument names' do
      @node.arg_names.should == [:x, :y]
    end
  end
end

describe SexpExtensions::IterNode do
  context 'with no parameters' do
    before :each do
      @node = s(:iter, s(), s(:args), s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has no parameter names' do
      @node.parameter_names.should == []
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:iter, s(), s(:args, :param), s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has 1 parameter name' do
      @node.parameter_names.should == s(:param)
    end
  end

  context 'with 2 parameters' do
    before :each do
      @node = s(:iter, s(), s(:args, :x, :y), s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has 2 parameter names' do
      @node.parameter_names.should == [:x, :y]
    end
  end
end

describe SexpExtensions::ModuleNode do
  context 'with a simple name' do
    subject do
      mod = ast(:module, :Fred, nil)
      mod
    end
    its(:name) { should == :Fred }
    its(:simple_name) { should == :Fred }
    its(:text_name) { should == 'Fred' }
    it 'has a simple full_name' do
      subject.full_name('').should == 'Fred'
    end
    it 'has a fq full_name' do
      subject.full_name('Blimey::O::Reilly').should == 'Blimey::O::Reilly::Fred'
    end
  end

  context 'with a scoped name' do
    subject do
      mod = ast(:module, s(:colon2, s(:const, :Foo), :Bar), nil)
      mod
    end
    its(:name) { should == s(:colon2, s(:const, :Foo), :Bar) }
    its(:simple_name) { should == :Bar }
    its(:text_name) { should == 'Foo::Bar' }
    it 'has a simple full_name' do
      subject.full_name('').should == 'Foo::Bar'
    end
    it 'has a fq full_name' do
      subject.full_name('Blimey::O::Reilly').should == 'Blimey::O::Reilly::Foo::Bar'
    end
  end
end
