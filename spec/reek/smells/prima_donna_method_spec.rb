require 'spec_helper'

require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe PrimaDonnaMethod do
  it 'should report nothing when method and bang counterpart exist' do
    'class C; def m; end; def m!; end; end'.should_not smell_of(PrimaDonnaMethod)
  end

  it 'should report PrimaDonnaMethod when only bang method exists' do
    'class C; def m!; end; end'.should smell_of(PrimaDonnaMethod)
  end

  describe 'the right smell' do
    let(:detector) { PrimaDonnaMethod.new('dummy_source') }
    let(:src)      { 'class C; def m!; end; end' }
    let(:ctx)      { CodeContext.new(nil, src.to_reek_source.syntax_tree) }

    it 'should be reported' do
      smells = detector.examine_context(ctx)
      warning = smells[0]

      warning.smell['class'].should    == 'PrimaDonnaMethod'
      warning.smell['subclass'].should == 'PrimaDonnaMethod'
      warning.lines.should             == [1]
    end
  end
end
