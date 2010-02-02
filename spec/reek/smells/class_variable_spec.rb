require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'class_variable')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'class_context')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'module_context')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')

include Reek::Core
include Reek::Smells

describe ClassVariable do
  before :each do
    @detector = ClassVariable.new('raffles')
    @class_variable = '@@things'
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
      before :each do
        @detector.examine_context(@ctx)
        @smells = @detector.smells_found
      end
      it 'records only that class variable' do
        @smells.length.should == 1
      end
      it 'records the variable name' do
        @smells.each do |warning|
          warning.smell['variable'].should == @class_variable
        end
      end
    end

    ['class', 'module'].each do |scope|
      context "declared in a #{scope}" do
        before :each do
          @ctx = ClassContext.from_s("#{scope} Fred; #{@class_variable} = {}; end")
        end

        it_should_behave_like 'one variable found'
      end

      context "used in a #{scope}" do
        before :each do
          @ctx = ClassContext.from_s("#{scope} Fred; def jim() #{@class_variable} = {}; end; end")
        end

        it_should_behave_like 'one variable found'
      end

      context "indexed in a #{scope}" do
        before :each do
          @ctx = ClassContext.from_s("#{scope} Fred; def jim() #{@class_variable}[mash] = {}; end; end")
        end

        it_should_behave_like 'one variable found'
      end

      context "declared and used in a #{scope}" do
        before :each do
          @ctx = ClassContext.from_s("#{scope} Fred; #{@class_variable} = {}; def jim() #{@class_variable} = {}; end; end")
        end

        it_should_behave_like 'one variable found'
      end

      context "used twice in a #{scope}" do
        before :each do
          @ctx = ClassContext.from_s("#{scope} Fred; def jeff() #{@class_variable} = {}; end; def jim() #{@class_variable} = {}; end; end")
        end

        it_should_behave_like 'one variable found'
      end
    end

  end

  it_should_behave_like 'SmellDetector'
end
