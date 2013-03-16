require 'spec_helper'
require 'reek/smells/uncommunicative_variable_name'
require 'reek/smells/smell_detector_shared'
require 'reek/core/code_parser'
require 'reek/core/sniffer'

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
      src = 'class Thing; def simple(fred) @x end end'
      src.should_not smell_of(UncommunicativeVariableName)
    end
    it 'reports one-letter fieldname in assignment' do
      src = 'class Thing; def simple(fred) @x = fred end end'
      src.should reek_of(:UncommunicativeVariableName, /@x/, /Thing/, /variable name/)
    end
  end

  context "local variable name" do
    it 'does not report one-word variable name' do
      'def help(fred) simple = jim(45) end'.should_not smell_of(UncommunicativeVariableName)
    end
    it 'does not report single underscore as a variable name' do
      'def help(fred) _ = jim(45) end'.should_not smell_of(UncommunicativeVariableName)
    end
    it 'reports one-letter variable name' do
      src = 'def simple(fred) x = jim(45) end'
      src.should smell_of(UncommunicativeVariableName,
        {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x'})
    end
    it 'reports name of the form "x2"' do
      src = 'def simple(fred) x2 = jim(45) end'
      src.should smell_of(UncommunicativeVariableName,
        {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x2'})
    end
    it 'reports long name ending in a number' do
      @bad_var = 'var123'
      src = "def simple(fred) #{@bad_var} = jim(45) end"
      src.should smell_of(UncommunicativeVariableName,
        {UncommunicativeVariableName::VARIABLE_NAME_KEY => @bad_var})
    end
    it 'reports variable name only once' do
      src = 'def simple(fred) x = jim(45); x = y end'
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      smells = @detector.examine_context(ctx)
      smells.length.should == 1
      smells[0].subclass.should == UncommunicativeVariableName::SMELL_SUBCLASS
      smells[0].smell[UncommunicativeVariableName::VARIABLE_NAME_KEY].should == 'x'
      smells[0].lines.should == [1,1]
    end
    it 'reports a bad name inside a block' do
      src = 'def clean(text) text.each { q2 = 3 } end'
      src.should smell_of(UncommunicativeVariableName,
        {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'q2'})
    end
    it 'reports variable name outside any method' do
      'class Simple; x = jim(45); end'.should reek_of(:UncommunicativeVariableName, /x/)
    end
  end

  context "block parameter name" do
    it "reports deep block parameter" do
      src = <<EOS
  def bad
    unless @mod then
      @sig.each { |x| x.to_s }
    end
  end
EOS
      src.should smell_of(UncommunicativeVariableName,
        {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x'})
    end

    it "reports all relevant block parameters" do
      src = <<-EOS
        def bad
          @foo.map { |x, y| x + y }
        end
      EOS
      src.should smell_of(UncommunicativeVariableName,
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x'},
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'y'})
    end

    it "reports block parameters used outside of methods" do
      src = <<-EOS
      class Foo
        @foo.map { |x| x * 2 }
      end
      EOS
      src.should smell_of(UncommunicativeVariableName,
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x'})
    end

    it "reports splatted block parameters correctly" do
      src = <<-EOS
        def bad
          @foo.map { |*y| y << 1 }
        end
      EOS
      src.should smell_of(UncommunicativeVariableName,
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'y'})
    end

    it "reports nested block parameters" do
      src = <<-EOS
        def bad
          @foo.map { |(x, y)| x + y }
        end
      EOS
      src.should smell_of(UncommunicativeVariableName,
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x'},
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'y'})
    end

    it "reports splatted nested block parameters" do
      src = <<-EOS
        def bad
          @foo.map { |(x, *y)| x + y }
        end
      EOS
      src.should smell_of(UncommunicativeVariableName,
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x'},
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'y'})
    end

    it "reports deeply nested block parameters" do
      src = <<-EOS
        def bad
          @foo.map { |(x, (y, z))| x + y + z }
        end
      EOS
      src.should smell_of(UncommunicativeVariableName,
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'x'},
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'y'},
                          {UncommunicativeVariableName::VARIABLE_NAME_KEY => 'z'})
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
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the correct values' do
      @warning.smell['variable_name'].should == 'x2'
      @warning.lines.should == [3,5]
    end
  end

  context 'when a smell is reported in a singleton method' do
    before :each do
      src = 'def self.bad() x2 = 4; end'
      ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
      @smells = @detector.examine_context(ctx)
      @warning = @smells[0]
    end

    it_should_behave_like 'common fields set correctly'

    it 'reports the fq context' do
      @warning.context.should == 'self.bad'
    end
  end
end
