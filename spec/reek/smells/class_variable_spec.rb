require 'spec_helper'
require 'reek/smells/class_variable'
require 'reek/core/module_context'
require 'reek/smells/smell_detector_shared'

include Reek::Core
include Reek::Smells

describe ClassVariable do
  before :each do
    @source_name = 'raffles'
    @detector = ClassVariable.new(@source_name)
    @class_variable = '@@things'
  end

  it_should_behave_like 'SmellDetector'

  context 'with no class variables' do
    it 'records nothing in the class' do
      exp = ast(:class, :Fred)
      expect(@detector.examine_context(CodeContext.new(nil, exp))).to be_empty
    end
    it 'records nothing in the module' do
      exp = ast(:module, :Fred)
      expect(@detector.examine_context(CodeContext.new(nil, exp))).to be_empty
    end
  end

  context 'with one class variable' do
    shared_examples_for 'one variable found' do
      before :each do
        ast = @src.to_reek_source.syntax_tree
        @smells = @detector.examine_context(CodeContext.new(nil, ast))
      end
      it 'records only that class variable' do
        expect(@smells.length).to eq(1)
      end
      it 'records the variable name' do
        expect(@smells[0].parameters[:name]).to eq(@class_variable)
      end
    end

    ['class', 'module'].each do |scope|
      context "declared in a #{scope}" do
        before :each do
          @src = "#{scope} Fred; #{@class_variable} = {}; end"
        end

        it_should_behave_like 'one variable found'
      end

      context "used in a #{scope}" do
        before :each do
          @src = "#{scope} Fred; def jim() #{@class_variable} = {}; end; end"
        end

        it_should_behave_like 'one variable found'
      end

      context "indexed in a #{scope}" do
        before :each do
          @src = "#{scope} Fred; def jim() #{@class_variable}[mash] = {}; end; end"
        end

        it_should_behave_like 'one variable found'
      end

      context "declared and used in a #{scope}" do
        before :each do
          @src = "
            #{scope} Fred
              #{@class_variable} = {}
              def jim() #{@class_variable} = {}; end
            end
          "
        end

        it_should_behave_like 'one variable found'
      end

      context "used twice in a #{scope}" do
        before :each do
          @src = "
            #{scope} Fred
              def jeff() #{@class_variable} = {}; end
              def jim()  #{@class_variable} = {}; end
            end
          "
        end

        it_should_behave_like 'one variable found'
      end
    end
  end

  it 'reports the correct fields' do
    src = <<EOS
module Fred
  #{@class_variable} = {}
end
EOS
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    @warning = @detector.examine_context(ctx)[0]
    expect(@warning.source).to eq(@source_name)
    expect(@warning.smell_category).to eq(ClassVariable.smell_category)
    expect(@warning.smell_type).to eq(ClassVariable.smell_type)
    expect(@warning.parameters[:name]).to eq(@class_variable)
    expect(@warning.lines).to eq([2])
  end
end
