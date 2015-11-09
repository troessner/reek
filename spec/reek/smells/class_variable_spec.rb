require_relative '../../spec_helper'
require_lib 'reek/smells/class_variable'
require_lib 'reek/context/module_context'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::ClassVariable do
  let(:class_variable) { '@@things' }
  let(:detector) { build(:smell_detector, smell_type: :ClassVariable) }

  it_should_behave_like 'SmellDetector'

  context 'with no class variables' do
    it 'records nothing in the class' do
      exp = sexp(:class, :Fred)
      expect(detector.inspect(Reek::Context::CodeContext.new(nil, exp))).to be_empty
    end

    it 'records nothing in the module' do
      exp = sexp(:module, :Fred)
      expect(detector.inspect(Reek::Context::CodeContext.new(nil, exp))).to be_empty
    end
  end

  context 'with one class variable' do
    shared_examples_for 'one variable found' do
      let(:ast) { Reek::Source::SourceCode.from(src).syntax_tree }
      let(:smells) { detector.inspect(Reek::Context::CodeContext.new(nil, ast)) }

      it 'records only that class variable' do
        expect(smells.length).to eq(1)
      end

      it 'records the variable name' do
        expect(smells[0].parameters[:name]).to eq(class_variable)
      end
    end

    ['class', 'module'].each do |scope|
      context "declared in a #{scope}" do
        let(:src) { "#{scope} Fred; #{class_variable} = {}; end" }
        it_should_behave_like 'one variable found'
      end

      context "used in a #{scope}" do
        let(:src) { "#{scope} Fred; def jim() #{class_variable} = {}; end; end" }
        it_should_behave_like 'one variable found'
      end

      context "indexed in a #{scope}" do
        let(:src) { "#{scope} Fred; def jim() #{class_variable}[mash] = {}; end; end" }
        it_should_behave_like 'one variable found'
      end

      context "declared and used in a #{scope}" do
        let(:src) do
          <<-EOS
            #{scope} Fred
              #{class_variable} = {}
              def jim() #{class_variable} = {}; end
            end
          EOS
        end
        it_should_behave_like 'one variable found'
      end

      context "used twice in a #{scope}" do
        let(:src) do
          <<-EOS
            #{scope} Fred
              def jeff() #{class_variable} = {}; end
              def jim()  #{class_variable} = {}; end
            end
          EOS
        end
        it_should_behave_like 'one variable found'
      end
    end
  end

  context 'when a smell is reported' do
    let(:warning) do
      src = <<-EOS
        module Fred
          #{class_variable} = {}
        end
      EOS
      ctx = Reek::Context::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
      detector.inspect(ctx).first
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      expect(warning.parameters[:name]).to eq(class_variable)
      expect(warning.lines).to eq([2])
    end
  end
end
