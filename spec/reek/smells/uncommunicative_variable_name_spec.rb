require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'uncommunicative_variable_name')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'code_parser')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'sniffer')

include Reek
include Reek::Smells

describe UncommunicativeVariableName do
  before :each do
    @source_name = 'wallamalloo'
    @detector = UncommunicativeVariableName.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context "field name" do
    it 'does not report use of one-letter fieldname' do
      'class Thing; def simple(fred) @x end end'.should_not reek_of(:UncommunicativeVariableName, /@x/, /Thing/, /variable name/)
    end
    it 'reports one-letter fieldname in assignment' do
      'class Thing; def simple(fred) @x = fred end end'.should reek_of(:UncommunicativeVariableName, /@x/, /Thing/, /variable name/)
    end
  end

  context "local variable name" do
    it 'does not report one-word variable name' do
      'def help(fred) simple = jim(45) end'.should_not reek
    end
    it 'reports one-letter variable name' do
      'def simple(fred) x = jim(45) end'.should reek_only_of(:UncommunicativeVariableName, /x/, /variable name/)
    end
    it 'reports name of the form "x2"' do
      'def simple(fred) x2 = jim(45) end'.should reek_only_of(:UncommunicativeVariableName, /x2/, /variable name/)
    end
    it 'reports long name ending in a number' do
      @bad_var = 'var123'
      src = "def simple(fred) #{@bad_var} = jim(45) end"
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @detector.examine(ctx)
      smells = @detector.smells_found.to_a
      smells.length.should == 1
      smells[0].subclass.should == UncommunicativeVariableName::SMELL_SUBCLASS
      smells[0].smell[UncommunicativeVariableName::VARIABLE_NAME_KEY].should == @bad_var
    end
    it 'reports variable name only once' do
      'def simple(fred) x = jim(45); x = y end'.should reek_only_of(:UncommunicativeVariableName, /x/)
    end
    it 'reports a bad name inside a block' do
      src = 'def clean(text) text.each { q2 = 3 } end'
      src.should reek_of(:UncommunicativeVariableName, /q2/)
    end
    it 'reports variable name outside any method' do
      'class Simple; x = jim(45); end'.should reek_of(:UncommunicativeVariableName, /x/)
    end
  end

  context "block parameter name" do
    it "reports parameter's name" do
      'def help() @stuff.each {|x|} end'.should reek_only_of(:UncommunicativeVariableName, /x/, /variable name/)
    end
    it "reports deep block parameter" do
      src = <<EOS
  def bad
    unless @mod then
      @sig.each { |x| x.to_s }
    end
  end
EOS
      src.should reek_only_of(:UncommunicativeVariableName, /'x'/)
    end
    it 'reports all bad block parameters' do
      source =<<EOS
  class Thing
    def bad(fred)
      @fred.each {|x| 4 - x }
      @jim.each {|y| y - 4 }
    end
  end
EOS

      source.should reek_of(:UncommunicativeVariableName, /'x'/)
      source.should reek_of(:UncommunicativeVariableName, /'y'/)
    end
  end

  context 'when a smell is reported' do
    before :each do
      src = <<EOS
def bad
  unless @mod then
     x2 = xy.to_s
     x2
     x2 = 56
  end
end
EOS
      source = src.to_reek_source
      sniffer = Core::Sniffer.new(source)
      mctx = Core::CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @detector.examine(mctx)
      @warning = @detector.smells_found.to_a[0]   # SMELL: too cumbersome!
    end
    it 'reports the source' do
      @warning.source.should == @source_name
    end
    it 'reports the class' do
      @warning.smell_class.should == 'UncommunicativeName'
    end
    it 'reports the subclass' do
      @warning.subclass.should == 'UncommunicativeVariableName'
    end
    it 'reports the variable name' do
      @warning.smell['variable_name'].should == 'x2'
    end
    it 'reports all line numbers' do
      @warning.lines.should == [3,5]
    end
  end

  context "several names" do
    it 'should report all bad names' do
      ruby = 'class Oof; def y(x) @z = x end end'
      ruby.should reek_of(:UncommunicativeParameterName, /'x'/)
      ruby.should reek_of(:UncommunicativeMethodName, /'y'/)
      ruby.should reek_of(:UncommunicativeVariableName, /'@z'/)
    end
  end
end
