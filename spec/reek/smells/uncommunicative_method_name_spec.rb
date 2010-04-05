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
        ctx.should_receive(:exp).at_least(:once).and_return(ast(:defn))
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
      it 'reports the source name' do
        @smells[0].source.should == @source_name
      end
    end
  end
end
