require File.dirname(__FILE__) + '/../../spec_helper.rb'

require 'reek/method_context'
require 'reek/smells/uncommunicative_name'

include Reek
include Reek::Smells

describe UncommunicativeName, "field name" do
  it 'should not report one-word field name' do
    #SMELL: shouldn't need comments, cos we're not testing that smell!
    # But this will only be succinctly testable after the move to listeners...
    '# class thing
class Thing; def help(fred) @simple end end'.should_not reek
  end
  it 'should report one-letter fieldname' do
    '# class thing
class Thing; def simple(fred) @x end end'.should reek_only_of(:UncommunicativeName, /@x/, /Thing/, /variable name/)
  end
  it 'should report name of the form "x2"' do
    '# class thing
class Thing; def simple(fred) @x2 end end'.should reek_only_of(:UncommunicativeName, /@x2/, /Thing/, /variable name/)
  end
  it 'should report long name ending in a number' do
    '# class thing
class Thing; def simple(fred) @field12 end end'.should reek_only_of(:UncommunicativeName, /@field12/, /Thing/, /variable name/)
  end
  it 'should report one-letter fieldname in assignment' do
    '# class thing
class Thing; def simple(fred) @x = fred end end'.should reek_only_of(:UncommunicativeName, /@x/, /Thing/, /variable name/)
  end
end

describe UncommunicativeName, "local variable name" do
  it 'should not report one-word variable name' do
    'def help(fred) simple = jim(45) end'.should_not reek
  end
  it 'should report one-letter variable name' do
    'def simple(fred) x = jim(45) end'.should reek_only_of(:UncommunicativeName, /x/, /variable name/)
  end
  it 'should report name of the form "x2"' do
    'def simple(fred) x2 = jim(45) end'.should reek_only_of(:UncommunicativeName, /x2/, /variable name/)
  end
  it 'should report long name ending in a number' do
    'def simple(fred) var123 = jim(45) end'.should reek_only_of(:UncommunicativeName, /var123/, /variable name/)
  end
  it 'should report variable name only once' do
    'def simple(fred) x = jim(45); x = y end'.should reek_only_of(:UncommunicativeName, /x/)
  end

  it 'should report a bad name inside a block' do
    src = 'def clean(text) text.each { q2 = 3 } end'
    src.should reek_of(:UncommunicativeName, /q2/)
  end

  context 'looking at the YAML' do
    before :each do
      src = <<EOS
def bad
  unless @mod then
     x2 = xy.to_s
     x2
  end
end
EOS
      @source_name = 'wallamalloo'
      @detector = UncommunicativeName.new(@source_name)
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
      @yaml.should match(/class:\s*UncommunicativeName/)
    end
    it 'reports the subclass' do
      @yaml.should match(/subclass:\s*UncommunicativeVariableName/)
    end
    it 'reports the variable name' do
      @yaml.should match(/variable_name:\s*x2/)
    end
    it 'reports the line number of the first use' do
      pending
      @yaml.should match(/lines:\s*- 3/)
    end
  end
end

describe UncommunicativeName, "parameter name" do
  it 'should not recognise *' do
    'def help(xray, *) basics(17) end'.should_not reek
  end
  it "should report parameter's name" do
    'def help(x) basics(17) end'.should reek_only_of(:UncommunicativeName, /x/, /variable name/)
  end
  it 'should report name of the form "x2"' do
    'def help(x2) basics(17) end'.should reek_only_of(:UncommunicativeName, /x2/, /variable name/)
  end
  it 'should report long name ending in a number' do
    'def help(param1) basics(17) end'.should reek_only_of(:UncommunicativeName, /param1/, /variable name/)
  end
end

describe UncommunicativeName, "block parameter name" do
  it "should report parameter's name" do
    'def help() @stuff.each {|x|} end'.should reek_only_of(:UncommunicativeName, /x/, /block/, /variable name/)
  end

  it "should report method name via if context" do
    src = <<EOS
def bad
  unless @mod then
    @sig.each { |x| x.to_s }
  end
end
EOS

    src.should reek_only_of(:UncommunicativeName, /'x'/)
  end
end

describe UncommunicativeName, "several names" do

  it 'should report all bad names' do
    ruby = 'class Oof; def y(x) @z = x end end'.sniff
    ruby.should reek_of(:UncommunicativeName, /'x'/)
    ruby.should reek_of(:UncommunicativeMethodName, /'y'/)
    ruby.should reek_of(:UncommunicativeName, /'@z'/)
  end

  it 'should report all bad block parameters' do
    source =<<EOS
class Thing
  def bad(fred)
    @fred.each {|x| 4 - x }
    @jim.each {|y| y - 4 }
  end
end
EOS

    source.should reek_of(:UncommunicativeName, /'x'/)
    source.should reek_of(:UncommunicativeName, /'y'/)
  end
end

require 'spec/reek/smells/smell_detector_shared'

describe UncommunicativeName do
  before :each do
    @detector = UncommunicativeName.new
  end

  it_should_behave_like 'SmellDetector'

  context 'accepting names' do
    it 'accepts Inline::C' do
      ctx = mock('context')
      ctx.should_receive(:full_name).and_return('Inline::C')
      @detector.accept?(ctx).should == true
    end
  end
end
