require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/code_parser'

include Reek

describe CodeParser, "with no method definitions" do
  it 'should report no problems for empty source code' do
    ''.should_not reek
  end
  it 'should report no problems for empty class' do
    'class Fred; end'.should_not reek
  end
end

describe CodeParser, 'with a global method definition' do
  it 'should report no problems for simple method' do
    'def Outermost::fred() true; end'.should_not reek
  end
end

describe CodeParser, 'when a yield is the receiver' do
  it 'should report no problems' do
    source = 'def values(*args)
  @to_sql += case
    when block_given? then " #{yield.to_sql}"
    else " values (#{args.to_sql})"
  end
  self
end'
    source.should_not reek
  end
end

describe CodeParser do
  it 'copes with a yield to an ivar' do
    'def options() ozz.on { |@list| @prompt = !@list } end'.should_not reek
  end
end

describe CodeParser do
  context 'with no class variables' do
    it 'records nothing in the class' do
      klass = ClassContext.from_s('class Fred; end')
      klass.class_variables.should be_empty
    end
    it 'records nothing in the module' do
      ctx = ModuleContext.from_s('module Fred; end')
      ctx.class_variables.should be_empty
    end
  end

  context 'with one class variable' do
    shared_examples_for 'one variable found' do
      it 'records the class variable' do
        @ctx.class_variables.should include(Name.new(:@@tools))
      end
      it 'records only that class variable' do
        @ctx.class_variables.length.should == 1
      end
    end

    context 'declared in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; @@tools = {}; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'used in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; def jim() @@tools = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'indexed in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; def jim() @@tools[mash] = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'declared and used in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; @@tools = {}; def jim() @@tools = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'used twice in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; def jeff() @@tools = {}; end; def jim() @@tools = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'declared in a module' do
      before :each do
        @ctx = ClassContext.from_s('module Fred; @@tools = {}; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'used in a module' do
      before :each do
        @ctx = ClassContext.from_s('module Fred; def jim() @@tools = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'indexed in a module' do
      before :each do
        @ctx = ClassContext.from_s('module Fred; def jim() @@tools[mash] = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'declared and used in a module' do
      before :each do
        @ctx = ClassContext.from_s('module Fred; @@tools = {}; def jim() @@tools = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end

    context 'used twice in a module' do
      before :each do
        @ctx = ClassContext.from_s('module Fred; def jeff() @@tools = {}; end; def jim() @@tools = {}; end; end')
      end

      it_should_behave_like 'one variable found'
    end
  end
end
