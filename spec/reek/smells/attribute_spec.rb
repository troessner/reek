#require File.dirname(__FILE__) + '/../../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'attribute')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'class_context')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek
include Reek::Smells

describe Attribute do
  before :each do
    @source_name = 'ticker'
    @detector = Attribute.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'with no attributes' do
    it 'records nothing in the class' do
      ctx = ClassContext.from_s('class Fred; end')
      @detector.attributes_in(ctx).should be_empty
    end
    it 'records nothing in the module' do
      ctx = ModuleContext.from_s('module Fred; end')
      @detector.attributes_in(ctx).should be_empty
    end
  end

  context 'with one attribute' do
    shared_examples_for 'one attribute found' do
      it 'records the attribute' do
        @detector.attributes_in(@ctx).should include([:property, 1])
      end
      it 'records only that attribute' do
        @detector.attributes_in(@ctx).length.should == 1
      end
    end

    context 'declared in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'reader in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr_reader :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'writer in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr_writer :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'accessor in a class' do
      before :each do
        @ctx = ClassContext.from_s('class Fred; attr_accessor :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'declared in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'reader in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr_reader :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'writer in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr_writer :property; end')
      end

      it_should_behave_like 'one attribute found'
    end

    context 'accessor in a module' do
      before :each do
        @ctx = ModuleContext.from_s('module Fred; attr_accessor :property; end')
      end

      it_should_behave_like 'one attribute found'
    end
  end

  context 'looking at the YAML' do
    before :each do
      @attr = 'prop'
      src = <<EOS
module Fred
  attr_writer :#{@attr}
end
EOS
      @ctx = ModuleContext.from_s(src)
      @detector.examine_context(@ctx)
      warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports the attribute' do
      @yaml.should match(/attribute:\s*#{@attr}/)
    end
    it 'reports the declaration line number' do
      @yaml.should match(/lines:[\s-]*3/)
    end
  end
end
