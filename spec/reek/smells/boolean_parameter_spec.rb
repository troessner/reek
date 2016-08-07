require_relative '../../spec_helper'
require_lib 'reek/smells/boolean_parameter'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::BooleanParameter do
  context 'parameter defaulted with boolean' do
    context 'in a method' do
      it 'reports a parameter defaulted to true' do
        src = 'def cc(arga = true); arga; end'
        expect(src).to reek_of(:BooleanParameter, name: 'arga')
      end

      it 'reports a parameter defaulted to false' do
        src = 'def cc(arga = false) end'
        expect(src).to reek_of(:BooleanParameter, name: 'arga')
      end

      it 'reports two parameters defaulted to booleans' do
        src = 'def cc(nowt, arga = true, argb = false, &blk) end'
        expect(src).to reek_of(:BooleanParameter, name: 'arga')
        expect(src).to reek_of(:BooleanParameter, name: 'argb')
      end

      it 'reports keyword parameters defaulted to booleans' do
        src = 'def cc(arga: true, argb: false) end'
        expect(src).to reek_of(:BooleanParameter, name: 'arga')
        expect(src).to reek_of(:BooleanParameter, name: 'argb')
      end

      it 'does not report regular parameters' do
        src = 'def cc(a, b) end'
        expect(src).not_to reek_of(:BooleanParameter)
      end

      it 'does not report array decomposition parameters' do
        src = 'def cc((a, b)) end'
        expect(src).not_to reek_of(:BooleanParameter)
      end

      it 'does not report keyword parameters with no default' do
        src = 'def cc(a:, b:) end'
        expect(src).not_to reek_of(:BooleanParameter)
      end

      it 'does not report keyword parameters with non-boolean default' do
        src = 'def cc(a: 42, b: "32") end'
        expect(src).not_to reek_of(:BooleanParameter)
      end
    end

    context 'in a singleton method' do
      it 'reports a parameter defaulted to true' do
        src = 'def self.cc(arga = true) end'
        expect(src).to reek_of(:BooleanParameter, name: 'arga')
      end

      it 'reports a parameter defaulted to false' do
        src = 'def fred.cc(arga = false) end'
        expect(src).to reek_of(:BooleanParameter, name: 'arga')
      end

      it 'reports two parameters defaulted to booleans' do
        src = 'def Module.cc(nowt, arga = true, argb = false, &blk) end'
        expect(src).to reek_of(:BooleanParameter, name: 'arga')
        expect(src).to reek_of(:BooleanParameter, name: 'argb')
      end
    end
  end

  context 'when a smell is reported' do
    let(:detector) { build(:smell_detector, smell_type: :BooleanParameter) }

    it_should_behave_like 'SmellDetector'

    context 'when a smell is reported' do
      let(:warning) do
        src = 'def cc(arga = true) end'
        ctx = Reek::Context::MethodContext.new(nil, Reek::Source::SourceCode.from(src).syntax_tree)
        detector.sniff(ctx).first
      end

      it_should_behave_like 'common fields set correctly'

      it 'reports the correct values' do
        expect(warning.parameters[:name]).to eq('arga')
        expect(warning.lines).to eq([1])
      end
    end
  end
end
