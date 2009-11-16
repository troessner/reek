require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/control_couple'

include Reek::Smells

describe ControlCouple do
  context 'conditional on a parameter' do
    it 'should report a ternary check on a parameter' do
      'def simple(arga) arga ? @ivar : 3 end'.should reek_only_of(:ControlCouple, /arga/)
    end
    it 'should not report a ternary check on an ivar' do
      'def simple(arga) @ivar ? arga : 3 end'.should_not reek
    end
    it 'should not report a ternary check on a lvar' do
      'def simple(arga) lvar = 27; lvar ? arga : @ivar end'.should_not reek
    end
    it 'should spot a couple inside a block' do
      'def blocks(arg) @text.map { |blk| arg ? blk : "#{blk}" } end'.should reek_of(:ControlCouple, /arg/)
    end
  end

  context 'parameter defaulted with boolean' do
    context 'in a method' do
      it 'reports a parameter defaulted to true' do
        'def cc(arga = true) end'.should reek_of(:ControlCouple, /arga/)
      end
      it 'reports a parameter defaulted to false' do
        'def cc(arga = false) end'.should reek_of(:ControlCouple, /arga/)
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def cc(nowt, arga = true, argb = false, &blk) end'
        src.should reek_of(:ControlCouple, /arga/)
        src.should reek_of(:ControlCouple, /argb/)
      end
    end

    context 'in a singleton method' do
      it 'reports a parameter defaulted to true' do
        'def self.cc(arga = true) end'.should reek_of(:ControlCouple, /arga/)
      end
      it 'reports a parameter defaulted to false' do
        'def fred.cc(arga = false) end'.should reek_of(:ControlCouple, /arga/)
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def Module.cc(nowt, arga = true, argb = false, &blk) end'
        src.should reek_of(:ControlCouple, /arga/)
        src.should reek_of(:ControlCouple, /argb/)
      end
    end
  end
end
