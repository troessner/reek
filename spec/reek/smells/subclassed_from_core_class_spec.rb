require_relative '../../spec_helper'
require_lib 'reek/smells/subclassed_from_core_class'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::SubclassedFromCoreClass do
  let(:detector) { described_class.new('max_methods' => 2) }
  let(:source_name) { 'string' }

  it_should_behave_like 'SmellDetector'

  context '...' do
    it 'should not report if the class has no ancestor' do
      src = <<-EOS
        class Dummy
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Context::ModuleContext.new(nil, syntax_tree)
      expect(detector.inspect(ctx)).to be_empty
    end

    it 'should report if we inherit from a core class' do
      src = <<-EOS
        class Dummy < Array
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Context::ModuleContext.new(nil, syntax_tree)
      smells = detector.inspect(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_type).to eq(described_class.smell_type)
      expect(smells[0].parameters[:count]).to eq(1)
    end

    it 'should not report on core-sounding classes in other namespaces' do
      src = <<-EOS
        class Dummy < My::Array
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Context::ModuleContext.new(nil, syntax_tree)
      expect(detector.inspect(ctx)).to be_empty
    end
  end

  context 'within a namespaced class' do
    it 'should report if we inherit from a core class' do
      pending 'curently failing'
      src = <<-EOS
        module Namespace
          class Dummy < ::Array
          end
        end
      EOS
      syntax_tree = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Context::ModuleContext.new(nil, syntax_tree)
      smells = detector.inspect(ctx)
      expect(smells.length).to eq(1)
      expect(smells[0].smell_type).to eq(described_class.smell_type)
      expect(smells[0].parameters[:count]).to eq(1)
    end
  end
end
