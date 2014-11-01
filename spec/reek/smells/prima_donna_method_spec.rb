require 'spec_helper'

require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe PrimaDonnaMethod do
  it 'should report nothing when method and bang counterpart exist' do
    expect('class C; def m; end; def m!; end; end').not_to smell_of(PrimaDonnaMethod)
  end

  it 'should report PrimaDonnaMethod when only bang method exists' do
    expect('class C; def m!; end; end').to smell_of(PrimaDonnaMethod)
  end

  describe 'the right smell' do
    let(:detector) { PrimaDonnaMethod.new('dummy_source') }
    let(:src)      { 'class C; def m!; end; end' }
    let(:ctx)      { CodeContext.new(nil, src.to_reek_source.syntax_tree) }

    it 'should be reported' do
      smells = detector.examine_context(ctx)
      warning = smells[0]

      expect(warning.smell['class']).to eq('PrimaDonnaMethod')
      expect(warning.smell['subclass']).to eq('PrimaDonnaMethod')
      expect(warning.lines).to eq([1])
    end
  end
end
