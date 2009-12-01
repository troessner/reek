require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/class_variable'
require 'reek/class_context'
require 'spec/reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe ClassVariable do
  before :each do
    @detector = ClassVariable.new
  end

  context 'with no class variables' do
    it 'records nothing in the class' do
      ctx = ClassContext.from_s('class Fred; end')
      @detector.class_variables_in(ctx).should be_empty
    end
    it 'records nothing in the module' do
      ctx = ModuleContext.from_s('module Fred; end')
      @detector.class_variables_in(ctx).should be_empty
    end
  end

  context 'with one class variable' do
    shared_examples_for 'one variable found' do
      it 'records the class variable' do
        @detector.class_variables_in(@ctx).should include(:@@tools)
      end
      it 'records only that class variable' do
        @detector.class_variables_in(@ctx).length.should == 1
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

  it_should_behave_like 'SmellDetector'
end
