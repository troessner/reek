require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/too_many_methods'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::TooManyMethods do
  before(:each) do
    @source_name = 'dummy_source'
    @detector = described_class.new(@source_name)
    @detector.configure_with 'max_methods' => 2
  end

  it_should_behave_like 'SmellDetector'

  context 'counting methods' do
    it 'should not report if we stay below max_methods' do
      src = <<-EOS
        class Dummy
          def m1; end
          def m2; end
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Core::ModuleContext.new(nil, syntax_tree)
      expect(@detector.examine_context(ctx)).to be_empty
    end

    it 'should report if we exceed max_methods' do
      src = <<-EOS
        class Dummy
          def m1; end
          def m2; end
          def m3; end
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Core::ModuleContext.new(nil, syntax_tree)
      smells = @detector.examine_context(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_type).to eq(described_class.smell_type)
      expect(smells[0].parameters[:count]).to eq(3)
    end
  end

  context 'with a nested module' do
    it 'stops at a nested module' do
      src = <<-EOS
        class Dummy
          def m1; end
          def m2; end
          module Hidden
            def m3; end
            def m4; end
            def m5; end
            def m6; end
          end
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Core::ModuleContext.new(nil, syntax_tree)
      expect(@detector.examine_context(ctx)).to be_empty
    end
  end

  it 'reports correctly when the class has many methods' do
    src = <<-EOS
      class Dummy
        def m1; end
        def m2; end
        def m3; end
      end
    EOS

    syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
    ctx = Reek::Core::ModuleContext.new(nil, syntax_tree)
    @warning = @detector.examine_context(ctx)[0]
    expect(@warning.source).to eq(@source_name)
    expect(@warning.smell_category).to eq(described_class.smell_category)
    expect(@warning.smell_type).to eq(described_class.smell_type)
    expect(@warning.parameters[:count]).to eq(3)
    expect(@warning.lines).to eq([1])
  end
end
