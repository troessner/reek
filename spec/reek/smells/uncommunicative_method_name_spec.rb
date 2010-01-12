#require File.dirname(__FILE__) + '/../../spec_helper.rb'

require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'uncommunicative_method_name')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'method_context')

include Reek
include Reek::Smells

describe UncommunicativeMethodName do
  before :each do
    @source_name = 'wallamalloo'
    @detector = UncommunicativeMethodName.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  it 'should not report one-word method name' do
    'def help(fred) basics(17) end'.should_not reek
  end
  it 'should report one-letter method name' do
    'def x(fred) basics(17) end'.should reek_only_of(:UncommunicativeMethodName, /x/)
  end
  it 'should report name of the form "x2"' do
    'def x2(fred) basics(17) end'.should reek_only_of(:UncommunicativeMethodName, /x2/)
  end
  it 'should report long name ending in a number' do
    'def method2(fred) basics(17) end'.should reek_only_of(:UncommunicativeMethodName, /method2/)
  end

  context 'looking at the YAML' do
    before :each do
      src = 'def bad3() end'
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @detector.examine(@mctx)
      warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
      @yaml = warning.to_yaml
    end
    it 'reports the source' do
      @yaml.should match(/source:\s*#{@source_name}/)
    end
    it 'reports the class' do
      @yaml.should match(/\sclass:\s*UncommunicativeName/)
    end
    it 'reports the subclass' do
      @yaml.should match(/subclass:\s*UncommunicativeMethodName/)
    end
    it 'reports the variable name' do
      @yaml.should match(/method_name:\s*bad3/)
    end
    it 'reports the line number of the method def' do
      @yaml.should match(/lines:\s*- 1/)
    end
  end
end
