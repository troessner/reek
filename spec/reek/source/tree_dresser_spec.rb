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
      @node.format.should == 'self'
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
