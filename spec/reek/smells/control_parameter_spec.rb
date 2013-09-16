require 'spec_helper'
require 'reek/smells/control_parameter'
require 'reek/smells/smell_detector_shared'

include Reek::Smells

describe ControlParameter do
  before(:each) do
    @source_name = 'lets get married'
    @detector = ControlParameter.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'conditional on a parameter' do
    it 'should report a ternary check on a parameter' do
      src = 'def simple(arga) arga ? @ivar : 3 end'
      src.should smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arga')
    end
    it 'should not report a ternary check on an ivar' do
      src = 'def simple(arga) @ivar ? arga : 3 end'
      src.should_not smell_of(ControlParameter)
    end
    it 'should not report a ternary check on a lvar' do
      src = 'def simple(arga) lvar = 27; lvar ? arga : @ivar end'
      src.should_not smell_of(ControlParameter)
    end
    it 'should spot a couple inside a block' do
      src = 'def blocks(arg) @text.map { |blk| arg ? blk : "#{blk}" } end'
      src.should smell_of(ControlParameter, ControlParameter::PARAMETER_KEY => 'arg')
    end
  end

  context 'when a smell is reported' do
    before :each do
      src = <<EOS
def things(arg)
  @text.map do |blk|
    arg ? blk : "blk"
  end
  puts "hello" if arg
end
EOS
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine(ctx)
      smells.length.should == 1
      @warning = smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'has the correct fields' do
      @warning.smell[ControlParameter::PARAMETER_KEY].should == 'arg'
      @warning.lines.should == [3, 5]
    end
  end
end
