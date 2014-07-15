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
      expect(@node.arg_names).to eq(s())
    end
    it 'has no parameter names' do
      expect(@node.parameter_names).to eq(s())
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('hello')
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:defn, :hello, s(:args, :param))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has 1 arg name' do
      expect(@node.arg_names).to eq(s(:param))
    end
    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq(s(:param))
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('hello')
    end
  end

  context 'with a block' do
    before :each do
      @node = s(:defn, :hello, s(:args, :param, :"&blk"))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has 1 arg name' do
      expect(@node.arg_names).to eq(s(:param))
    end
    it 'has 2 parameter names' do
      expect(@node.parameter_names).to eq(s(:param, :"&blk"))
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('hello')
    end
  end

  context 'with 1 defaulted parameter' do
    before :each do
      @node = s(:defn, :hello, s(:args, s(:lasgn, :param, s(:array))))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has 1 arg name' do
      expect(@node.arg_names).to eq(s(:param))
    end
    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq(s(:param))
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('hello')
    end
  end

  context 'with a body with 2 statements' do
    before :each do
      @node = s(:defn, :hello, s(:args), s(:first), s(:second))
      @node.extend(SexpExtensions::DefnNode)
    end

    it 'has 2 body statements' do
      expect(@node.body).to eq(s(s(:first), s(:second)))
    end

    it 'has a body extended with SexpNode' do
      b = @node.body
      expect((class << b; self; end).included_modules.first).to eq(SexpNode)
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
      expect(@node.arg_names).to eq(s())
    end
    it 'has no parameter names' do
      expect(@node.parameter_names).to eq(s())
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#obj.hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('obj.hello')
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args, :param))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has 1 arg name' do
      expect(@node.arg_names).to eq(s(:param))
    end
    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq(s(:param))
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#obj.hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('obj.hello')
    end
  end

  context 'with a block' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args, :param, :"&blk"))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has 1 arg name' do
      expect(@node.arg_names).to eq(s(:param))
    end
    it 'has 2 parameter names' do
      expect(@node.parameter_names).to eq(s(:param, :"&blk"))
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#obj.hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('obj.hello')
    end
  end

  context 'with 1 defaulted parameter' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args, s(:lasgn, :param, s(:array))))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has 1 arg name' do
      expect(@node.arg_names).to eq(s(:param))
    end
    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq(s(:param))
    end
    it 'includes outer scope in its full name' do
      expect(@node.full_name('Fred')).to eq('Fred#obj.hello')
    end
    it 'includes no marker in its full name with empty outer scope' do
      expect(@node.full_name('')).to eq('obj.hello')
    end
  end

  context 'with a body with 2 statements' do
    before :each do
      @node = s(:defs, s(:self), :hello, s(:args), s(:first), s(:second))
      @node.extend(SexpExtensions::DefsNode)
    end

    it 'has 2 body statements' do
      expect(@node.body).to eq(s(s(:first), s(:second)))
    end

    it 'has a body extended with SexpNode' do
      b = @node.body
      expect((class << b; self; end).included_modules.first).to eq(SexpNode)
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
      expect(@node.parameter_names).to eq(nil)
    end
  end

  context 'with 1 literal parameter' do
    before :each do
      @node = s(:call, nil, :hello, s(:lit, :param))
      @node.extend(SexpExtensions::CallNode)
    end
    it 'has 1 argument name' do
      expect(@node.arg_names).to eq([:param])
    end
  end

  context 'with 2 literal parameters' do
    before :each do
      @node = s(:call, nil, :hello, s(:lit, :x), s(:lit, :y))
      @node.extend(SexpExtensions::CallNode)
    end
    it 'has 2 argument names' do
      expect(@node.arg_names).to eq([:x, :y])
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
      expect(@node.parameter_names).to eq([])
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:iter, s(), s(:args, :param), s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has 1 parameter name' do
      expect(@node.parameter_names).to eq(s(:param))
    end
  end

  context 'with 2 parameters' do
    before :each do
      @node = s(:iter, s(), s(:args, :x, :y), s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has 2 parameter names' do
      expect(@node.parameter_names).to eq([:x, :y])
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
      expect(subject.name).to eq(:Fred)
    end

    it 'has the correct #simple_name' do
      expect(subject.simple_name).to eq(:Fred)
    end

    it 'has the correct #text_name' do
      expect(subject.text_name).to eq('Fred')
    end

    it 'has a simple full_name' do
      expect(subject.full_name('')).to eq('Fred')
    end
    it 'has a fq full_name' do
      expect(subject.full_name('Blimey::O::Reilly')).to eq('Blimey::O::Reilly::Fred')
    end
  end

  context 'with a scoped name' do
    subject do
      mod = ast(:module, s(:colon2, s(:const, :Foo), :Bar), nil)
      mod
    end

    it 'has the correct #name' do
      expect(subject.name).to eq(s(:colon2, s(:const, :Foo), :Bar))
    end

    it 'has the correct #simple_name' do
      expect(subject.simple_name).to eq(:Bar)
    end

    it 'has the correct #text_name' do
      expect(subject.text_name).to eq('Foo::Bar')
    end

    it 'has a simple full_name' do
      expect(subject.full_name('')).to eq('Foo::Bar')
    end

    it 'has a fq full_name' do
      expect(subject.full_name('Blimey::O::Reilly')).to eq('Blimey::O::Reilly::Foo::Bar')
    end
  end
end
