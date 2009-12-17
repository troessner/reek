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
end

require 'spec/reek/smells/smell_detector_shared'

describe ControlCouple do
  before(:each) do
    @detector = ControlCouple.new
  end

  it_should_behave_like 'SmellDetector'

  it 'records the parameter in the YAML report' do
    param_name = 'blah'
    ctx = mock('method_context', :null_object => true)
    ctx.should_receive(:tests_a_parameter?).and_return(true)
    ctx.should_receive(:if_expr).and_return(s(:lvar, param_name))
    @detector.examine_context(ctx)
    @detector.smells_found.each do |warning|
      warning.to_yaml.should match(/parameter:[\s]*#{param_name}/)
    end
  end
end
