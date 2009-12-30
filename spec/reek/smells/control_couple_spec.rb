require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/smells/control_couple'
require 'spec/reek/smells/smell_detector_shared'

include Reek::Smells

describe ControlCouple do
  before(:each) do
    @source_name = 'lets get married'
    @detector = ControlCouple.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

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

  context 'looking at the YAML' do
    before :each do
      src = <<EOS
def things(arg)
  @text.map do |blk|
    arg ? blk : "blk"
  end
  puts "hello" if arg
end
EOS
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @detector.examine_context(@mctx)
      warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports the source' do
      @yaml.should match(/source:\s*#{@source_name}/)
    end
    it 'reports the class' do
      @yaml.should match(/class:\s*ControlCouple/)
    end
    it 'reports the subclass' do
      @yaml.should match(/subclass:\s*ControlParameter/)
    end
    it 'reports the control parameter' do
      @yaml.should match(/parameter:\s*arg/)
    end
    it 'reports all conditional locations' do
      @yaml.should match(/lines:\s*- 3\s*- 6/)
    end
  end
end
