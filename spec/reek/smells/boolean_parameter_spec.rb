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

  context 'looking at the YAML' do
    before :each do
      src = 'def cc(arga = true) end'
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @detector.examine(@mctx)
      warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports the class' do
      pending
      @yaml.should match(/class:\s*ControlCouple/)
    end
    it 'reports the subclass' do
      pending
      @yaml.should match(/subclass:\s*BooleanParameter/)
    end
    it 'reports the parameter name' do
      @yaml.should match(/parameter:\s*arga/)
    end
    it 'reports the correct line' do
      pending
      @yaml.should match(/lines:\s*- 1/)
    end
  end
end
