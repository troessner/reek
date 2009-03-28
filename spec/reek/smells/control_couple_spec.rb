require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/control_couple'

include Reek::Smells

describe ControlCouple do
  it 'should report a ternary check on a parameter' do
    'def simple(arga) arga ? @ivar : 3 end'.should reek_of(:ControlCouple, /arga/)
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
