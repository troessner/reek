require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/boolean_parameter'

include Reek::Smells

describe BooleanParameter do
  context 'parameter defaulted with boolean' do
    context 'in a method' do
      it 'reports a parameter defaulted to true' do
        'def cc(arga = true) end'.should reek_of(:BooleanParameter, /arga/)
      end
      it 'reports a parameter defaulted to false' do
        'def cc(arga = false) end'.should reek_of(:BooleanParameter, /arga/)
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def cc(nowt, arga = true, argb = false, &blk) end'
        src.should reek_of(:BooleanParameter, /arga/)
        src.should reek_of(:BooleanParameter, /argb/)
      end
    end

    context 'in a singleton method' do
      it 'reports a parameter defaulted to true' do
        'def self.cc(arga = true) end'.should reek_of(:BooleanParameter, /arga/)
      end
      it 'reports a parameter defaulted to false' do
        'def fred.cc(arga = false) end'.should reek_of(:BooleanParameter, /arga/)
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def Module.cc(nowt, arga = true, argb = false, &blk) end'
        src.should reek_of(:BooleanParameter, /arga/)
        src.should reek_of(:BooleanParameter, /argb/)
      end
    end
  end
end

require 'spec/reek/smells/smell_detector_shared'

describe BooleanParameter do
  before(:each) do
    @detector = BooleanParameter.new
  end

  it_should_behave_like 'SmellDetector'
end
