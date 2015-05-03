require_relative '../../spec_helper'
require_relative '../../../lib/reek/core/code_context'
require_relative '../../../lib/reek/smells/irresponsible_module'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::IrresponsibleModule do
  before(:each) do
    @bad_module_name = 'WrongUn'
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :IrresponsibleModule, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  it 'does not report re-opened modules' do
    src = <<-EOS
      # Abstract base class
      class C; end

      class C; def foo; end; end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'does not report a class having a comment' do
    src = <<-EOS
      # test class
      class Responsible; end
    EOS
    ctx = Reek::Core::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
    expect(@detector.examine_context(ctx)).to be_empty
  end

  it 'reports a class without a comment' do
    src = "class #{@bad_module_name}; end"
    ctx = Reek::Core::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
    smells = @detector.examine_context(ctx)
    expect(smells.length).to eq(1)
    expect(smells[0].smell_category).to eq(Reek::Smells::IrresponsibleModule.smell_category)
    expect(smells[0].smell_type).to eq(Reek::Smells::IrresponsibleModule.smell_type)
    expect(smells[0].lines).to eq([1])
    expect(smells[0].parameters[:name]).to eq(@bad_module_name)
  end

  it 'reports a class with an empty comment' do
    src = <<-EOS
      #
      #
      #
      class #{@bad_module_name}; end
    EOS
    expect(src).to reek_of :IrresponsibleModule
  end

  it 'reports a class with a preceding comment with intermittent material' do
    src = <<-EOS
      # This is a valid comment

      require 'foo'

      class Bar; end
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'reports a fq module name correctly' do
    src = 'class Foo::Bar; end'
    ctx = Reek::Core::CodeContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
    smells = @detector.examine_context(ctx)
    expect(smells.length).to eq(1)
    expect(smells[0].smell_category).to eq(described_class.smell_category)
    expect(smells[0].smell_type).to eq(described_class.smell_type)
    expect(smells[0].parameters[:name]).to eq('Foo::Bar')
    expect(smells[0].context).to match(/#{smells[0].parameters['name']}/)
  end
end
