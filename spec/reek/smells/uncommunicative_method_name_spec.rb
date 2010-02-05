require File.join(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))), 'spec_helper')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'smells', 'uncommunicative_method_name')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_detector_shared')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'code_parser')
require File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'lib', 'reek', 'core', 'sniffer')

include Reek
include Reek::Smells

describe UncommunicativeMethodName do
  before :each do
    @source_name = 'wallamalloo'
    @detector = UncommunicativeMethodName.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  ['help', '+', '-', '/', '*'].each do |method_name|
    it "accepts the method name '#{method_name}'" do
      "def #{method_name}(fred) basics(17) end".should_not reek
    end
  end

  ['x', 'x2', 'method2'].each do |method_name|
    context 'with a bad name' do
      before :each do
        @full_name = 'anything you like'
        ctx = mock('method', :null_object => true)
        ctx.should_receive(:name).and_return(method_name)
        ctx.should_receive(:full_name).at_least(:once).and_return(@full_name)
        ctx.should_receive(:exp).and_return(ast(:defn))
        @detector.examine_context(ctx)
        @smells = @detector.smells_found.to_a
      end

      it 'records only that attribute' do
        @smells.length.should == 1
      end
      it 'reports the attribute name' do
        @smells[0].smell[UncommunicativeMethodName::METHOD_NAME_KEY].should == method_name
      end
      it 'reports the declaration line number' do
        @smells[0].lines.should == [1]
      end
      it 'reports the correct smell class' do
        @smells[0].smell_class.should == UncommunicativeMethodName::SMELL_CLASS
      end
      it 'reports the correct smell subclass' do
        @smells[0].subclass.should == UncommunicativeMethodName::SMELL_SUBCLASS
      end
      it 'reports the context fq name' do
        @smells[0].context.should == @full_name
      end
    end
  end

  context 'looking at the YAML' do
    before :each do
      src = 'def bad3() end'
      source = src.to_reek_source
      sniffer = Core::Sniffer.new(source)
      @mctx = Core::CodeParser.new(sniffer).process_defn(source.syntax_tree)
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
