require 'spec_helper'
require 'reek/smells/boolean_parameter'
require 'reek/smells/smell_detector_shared'

include Reek::Smells

describe BooleanParameter do
  context 'parameter defaulted with boolean' do
    context 'in a method' do
      it 'reports a parameter defaulted to true' do
        src = 'def cc(arga = true) end'
        src.should smell_of(BooleanParameter, BooleanParameter::PARAMETER_KEY => 'arga')
      end
      it 'reports a parameter defaulted to false' do
        src = 'def cc(arga = false) end'
        src.should smell_of(BooleanParameter, BooleanParameter::PARAMETER_KEY => 'arga')
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def cc(nowt, arga = true, argb = false, &blk) end'
        src.should smell_of(BooleanParameter,
          {BooleanParameter::PARAMETER_KEY => 'arga'},
          {BooleanParameter::PARAMETER_KEY => 'argb'})
      end
    end

    context 'in a singleton method' do
      it 'reports a parameter defaulted to true' do
        src = 'def self.cc(arga = true) end'
        src.should smell_of(BooleanParameter, BooleanParameter::PARAMETER_KEY => 'arga')
      end
      it 'reports a parameter defaulted to false' do
        src = 'def fred.cc(arga = false) end'
        src.should smell_of(BooleanParameter, BooleanParameter::PARAMETER_KEY => 'arga')
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def Module.cc(nowt, arga = true, argb = false, &blk) end'
        src.should smell_of(BooleanParameter,
          {BooleanParameter::PARAMETER_KEY => 'arga'},
          {BooleanParameter::PARAMETER_KEY => 'argb'})
      end
    end
  end

  context 'when a smell is reported' do
    before(:each) do
      @source_name = 'smokin'
      @detector = BooleanParameter.new(@source_name)
    end

    it_should_behave_like 'SmellDetector'

    it 'reports the fields correctly' do
      src = 'def cc(arga = true) end'
      ctx = MethodContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine(ctx)
      smells = @detector.smells_found.to_a
      smells.length.should == 1
      smells[0].smell_class.should == BooleanParameter::SMELL_CLASS
      smells[0].smell[BooleanParameter::PARAMETER_KEY].should == 'arga'
      smells[0].source.should == @source_name
      smells[0].smell_class.should == BooleanParameter::SMELL_CLASS
      smells[0].subclass.should == BooleanParameter::SMELL_SUBCLASS
      smells[0].lines.should == [1]
    end
  end
end
