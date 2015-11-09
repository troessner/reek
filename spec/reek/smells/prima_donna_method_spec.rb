require_relative '../../spec_helper'
require_lib 'reek/context/module_context'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::PrimaDonnaMethod do
  it 'should report nothing when method and bang counterpart exist' do
    expect('class C; def m; end; def m!; end; end').not_to reek_of(:PrimaDonnaMethod)
  end

  it 'should report PrimaDonnaMethod when only bang method exists' do
    expect('class C; def m!; end; end').to reek_of(:PrimaDonnaMethod)
  end

  describe 'the right smell' do
    let(:detector) { build(:smell_detector, smell_type: :PrimaDonnaMethod) }
    let(:src)      { 'class C; def m!; end; end' }
    let(:ctx)      do
      Reek::Context::ModuleContext.new(nil,
                                       Reek::Source::SourceCode.from(src).syntax_tree)
    end

    it 'should be reported' do
      smells = detector.inspect(ctx)
      warning = smells[0]

      expect(warning.smell_category).to eq('PrimaDonnaMethod')
      expect(warning.smell_type).to eq('PrimaDonnaMethod')
      expect(warning.lines).to eq([1])
    end
  end
end
