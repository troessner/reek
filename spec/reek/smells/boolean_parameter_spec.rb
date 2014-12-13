require 'spec_helper'
require 'reek/smells/boolean_parameter'
require 'reek/smells/smell_detector_shared'

include Reek::Smells

describe BooleanParameter do
  context 'parameter defaulted with boolean' do
    context 'in a method' do
      it 'reports a parameter defaulted to true' do
        src = 'def cc(arga = true) end'
        expect(src).to smell_of(BooleanParameter, name: 'arga')
      end
      it 'reports a parameter defaulted to false' do
        src = 'def cc(arga = false) end'
        expect(src).to smell_of(BooleanParameter, name: 'arga')
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def cc(nowt, arga = true, argb = false, &blk) end'
        expect(src).to smell_of(BooleanParameter,
                                { name: 'arga' },
                                { name: 'argb' })
      end
    end

    context 'in a singleton method' do
      it 'reports a parameter defaulted to true' do
        src = 'def self.cc(arga = true) end'
        expect(src).to smell_of(BooleanParameter, name: 'arga')
      end
      it 'reports a parameter defaulted to false' do
        src = 'def fred.cc(arga = false) end'
        expect(src).to smell_of(BooleanParameter, name: 'arga')
      end
      it 'reports two parameters defaulted to booleans' do
        src = 'def Module.cc(nowt, arga = true, argb = false, &blk) end'
        expect(src).to smell_of(BooleanParameter,
                                { name: 'arga' },
                                { name: 'argb' })
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
      expect(smells.length).to eq(1)
      expect(smells[0].smell_category).to eq(BooleanParameter.smell_category)
      expect(smells[0].parameters[:name]).to eq('arga')
      expect(smells[0].source).to eq(@source_name)
      expect(smells[0].smell_type).to eq(BooleanParameter.smell_type)
      expect(smells[0].lines).to eq([1])
    end
  end
end
