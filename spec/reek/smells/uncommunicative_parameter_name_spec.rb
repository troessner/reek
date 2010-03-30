require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'uncommunicative_parameter_name')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'method_context')

include Reek::Core
include Reek::Smells

describe UncommunicativeParameterName do
  before :each do
    @source_name = 'wallamalloo'
    @detector = UncommunicativeParameterName.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context "parameter name" do
    ['obj.', ''].each do |host|
      it 'does not recognise *' do
        "def #{host}help(xray, *) basics(17) end".should_not reek
      end
      it "reports parameter's name" do
        "def #{host}help(x) basics(17) end".should reek_only_of(:UncommunicativeParameterName, /x/, /parameter name/)
      end

      context 'with a name of the form "x2"' do
        before :each do
          @bad_param = 'x2'
          src = "def #{host}help(#{@bad_param}) basics(17) end"
          ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
          @detector.examine(ctx)
          @smells = @detector.smells_found.to_a
        end
        it 'reports only 1 smell' do
          @smells.length.should == 1
        end
        it 'reports uncommunicative parameter name' do
          @smells[0].subclass.should == UncommunicativeParameterName::SMELL_SUBCLASS
        end
        it 'reports the parameter name' do
          @smells[0].smell[UncommunicativeParameterName::PARAMETER_NAME_KEY].should == @bad_param
        end
      end
      it 'reports long name ending in a number' do
        @bad_param = 'param2'
        src = "def #{host}help(#{@bad_param}) basics(17) end"
        ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
        @detector.examine(ctx)
        smells = @detector.smells_found.to_a
        smells.length.should == 1
        smells[0].subclass.should == UncommunicativeParameterName::SMELL_SUBCLASS
        smells[0].smell[UncommunicativeParameterName::PARAMETER_NAME_KEY].should == @bad_param
      end
    end
  end

  context 'looking at the YAML' do
    before :each do
      src = 'def bad(good, bad2, good_again) end'
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
      @yaml.should match(/subclass:\s*UncommunicativeParameterName/)
    end
    it 'reports the variable name' do
      @yaml.should match(/parameter_name:\s*bad2/)
    end
    it 'reports the line number of the declaration' do
      @yaml.should match(/lines:\s*- 1/)
    end
  end
end
