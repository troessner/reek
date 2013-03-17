require 'spec_helper'
require 'reek/smells/attribute'
require 'reek/core/module_context'
require 'reek/smells/smell_detector_shared'

include Reek::Core
include Reek::Smells

describe Attribute do
  before :each do
    @source_name = 'ticker'
    @detector = Attribute.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'with no attributes' do
    it 'records nothing in the module' do
      src = 'module Fred; end'
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine_context(ctx).should be_empty
    end
  end

  context 'with one attribute' do
    before :each do
      @attr_name = 'super_thing'
    end

    shared_examples_for 'one attribute found' do
      before :each do
        ctx = CodeContext.new(nil, @src.to_reek_source.syntax_tree)
        @smells = @detector.examine_context(ctx)
      end

      it 'records only that attribute' do
        @smells.length.should == 1
      end
      it 'reports the attribute name' do
        @smells[0].smell[Attribute::ATTRIBUTE_KEY].should == @attr_name
      end
      it 'reports the declaration line number' do
        @smells[0].lines.should == [1]
      end
      it 'reports the correct smell class' do
        @smells[0].smell_class.should == Attribute::SMELL_CLASS
      end
      it 'reports the context fq name' do
        @smells[0].context.should == 'Fred'
      end
    end

    context 'declared in a class' do
      before :each do
        @src = "class Fred; attr :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end

    context 'reader in a class' do
      before :each do
        @src = "class Fred; attr_reader :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end

    context 'writer in a class' do
      before :each do
        @src = "class Fred; attr_writer :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end

    context 'accessor in a class' do
      before :each do
        @src = "class Fred; attr_accessor :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end

    context 'declared in a module' do
      before :each do
        @src = "module Fred; attr :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end

    context 'reader in a module' do
      before :each do
        @src = "module Fred; attr_reader :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end

    context 'writer in a module' do
      before :each do
        @src = "module Fred; attr_writer :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end

    context 'accessor in a module' do
      before :each do
        @src = "module Fred; attr_accessor :#{@attr_name}; end"
      end

      it_should_behave_like 'one attribute found'
    end
  end
end
