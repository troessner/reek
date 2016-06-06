require_relative '../../spec_helper'
require_lib 'reek/context/module_context'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::PrimaDonnaMethod do
  it 'reports the right values' do
    src = 'class C; def m!; end; end'
    expect(src).to reek_of :PrimaDonnaMethod,
                           lines: [1],
                           name: 'C',
                           message: 'has prima donna method `m!`'
  end

  it 'should report nothing when method and bang counterpart exist' do
    expect('class C; def m; end; def m!; end; end').not_to reek_of(:PrimaDonnaMethod)
  end

  it 'should report PrimaDonnaMethod when only bang method exists' do
    expect('class C; def m!; end; end').to reek_of(:PrimaDonnaMethod)
  end
end
