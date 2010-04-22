require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'source', 'tree_dresser')

include Reek::Source

describe TreeDresser do
  before(:each) do
    @dresser = TreeDresser.new
  end
  it 'maps :if to IfNode' do
    @dresser.extensions_for(:if).should == 'IfNode'
  end
  it 'maps :call to CallNode' do
    @dresser.extensions_for(:call).should == 'CallNode'
  end
end

describe SexpNode do
  context 'format' do
    it 'formats self' do
      @node = s(:self)
      @node.extend(SexpNode)
      @node.format_ruby.should == 'self'
    end
  end

  context 'hash' do
    it 'hashes equal for equal sexps' do
      node1 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 4), :fred))
      node2 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 4), :fred))
      node1.hash.should == node2.hash
    end
    it 'hashes diferent for diferent sexps' do
      node1 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 4), :fred))
      node2 = ast(:defn, s(:const2, :Fred, :jim), s(:call, :+, s(:lit, 3), :fred))
      node1.hash.should_not == node2.hash
    end
  end
end

describe SexpExtensions::DefnNode do
  context 'with no parameters' do
    before :each do
      @node = s(:defn, :hello, s(:args))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has no parameters' do
      @node.parameters.should == s(:args)
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
    it 'has 1 parameter' do
      @node.parameters.should == s(:args, :param)
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
    it 'has 1 parameter' do
      @node.parameters.should == s(:args, :param, :"&blk")
    end
    it 'has 1 parameter name' do
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
      @node = s(:defn, :hello, s(:args, :param, s(:block, s(:lasgn, :param, s(:array)))))
      @node.extend(SexpExtensions::DefnNode)
    end
    it 'has 1 parameter' do
      @node.parameters.should == s(:args, :param)
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
end

describe SexpExtensions::DefsNode do
  context 'with no parameters' do
    before :each do
      @node = s(:defs, :obj, :hello, s(:args))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has no parameters' do
      @node.parameters.should == s(:args)
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
    it 'has 1 parameter' do
      @node.parameters.should == s(:args, :param)
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
    it 'has 1 parameter' do
      @node.parameters.should == s(:args, :param, :"&blk")
    end
    it 'has 1 parameter name' do
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
      @node = s(:defs, :obj, :hello, s(:args, :param, s(:block, s(:lasgn, :param, s(:array)))))
      @node.extend(SexpExtensions::DefsNode)
    end
    it 'has 1 parameter' do
      @node.parameters.should == s(:args, :param)
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
end

describe SexpExtensions::IterNode do
  context 'with no parameters' do
    before :each do
      @node = s(:iter, s(), nil, s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has no parameters' do
      @node.parameters.should == []
    end
    it 'has no parameter names' do
      @node.parameter_names.should == []
    end
  end

  context 'with 1 parameter' do
    before :each do
      @node = s(:iter, s(), s(:lasgn, :param), s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has 1 parameter' do
      @node.parameters.should == s(:lasgn, :param)
    end
    it 'has 1 parameter name' do
      @node.parameter_names.should == s(:param)
    end
  end

  context 'with 2 parameters' do
    before :each do
      @node = s(:iter, s(), s(:masgn, s(:array, s(:lasgn, :x), s(:lasgn, :y))), s())
      @node.extend(SexpExtensions::IterNode)
    end
    it 'has 1 parameter' do
      @node.parameters.should == s(:masgn, s(:array, s(:lasgn, :x), s(:lasgn, :y)))
    end
    it 'has 1 parameter name' do
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
