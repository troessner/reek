require_relative '../../spec_helper'
require_relative '../../../lib/reek/context/code_context'
require_relative '../../../lib/reek/smells/irresponsible_module'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::IrresponsibleModule do
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
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'reports a class without a comment' do
    src = 'class BadClass; end'
    expect(src).to reek_of :IrresponsibleModule, name: 'BadClass'
  end

  it 'reports a class with an empty comment' do
    src = <<-EOS
      #
      #
      #
      class BadClass; end
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

  it 'reports a class with a trailing comment' do
    src = <<-EOS
      class BadClass
      end # end BadClass
    EOS
    expect(src).to reek_of(:IrresponsibleModule)
  end

  it 'reports a fully qualified class name correctly' do
    src = 'class Foo::Bar; end'
    expect(src).to reek_of :IrresponsibleModule, name: 'Foo::Bar'
  end

  context 'when a smell is reported' do
    before do
      @source_name = 'dummy_source'
      @detector = build(:smell_detector, smell_type: :IrresponsibleModule, source: @source_name)
    end

    it_should_behave_like 'SmellDetector'
  end
end
