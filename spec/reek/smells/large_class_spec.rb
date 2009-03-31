require File.dirname(__FILE__) + '/../../spec_helper.rb'
require 'reek/code_parser'
require 'reek/report'
require 'reek/smells/large_class'

include Reek
include Reek::Smells

describe LargeClass do

  class BigOne
    26.times do |i|
      define_method "method#{i}".to_sym do
        @melting
      end
    end
  end

  before(:each) do
    @rpt = Report.new
    @cchk = CodeParser.new(@rpt, SmellConfig.new.smell_listeners)
  end

  it 'should not report short class' do
    class ShortClass
      def method1() @var1; end
      def method2() @var2; end
      def method3() @var3; end
      def method4() @var4; end
      def method5() @var5; end
      def method6() @var6; end
    end
    @cchk.check_object(ShortClass)
    @rpt.should be_empty
  end

  it 'should report large class' do
    @cchk.check_object(BigOne)
    @rpt.length.should == 1
  end

  it 'should report class name' do
    @cchk.check_object(BigOne)
    @rpt[0].report.should match(/BigOne/)
  end

  describe 'when exceptions are listed' do
    before :each do
      @ctx = ClassContext.create(StopContext.new, [0, :Humungous])
      30.times { |num| @ctx.record_method("method#{num}") }
      @config = LargeClass.default_config
    end

    it 'should ignore first excepted name' do
      @config[LargeClass::EXCLUDE_KEY] = ['Humungous']
      lc = LargeClass.new(@config)
      lc.examine(@ctx, @rpt).should == false
      @rpt.length.should == 0
    end

    it 'should ignore second excepted name' do
      @config[LargeClass::EXCLUDE_KEY] = ['Oversized', 'Humungous']
      lc = LargeClass.new(@config)
      lc.examine(@ctx, @rpt).should == false
      @rpt.length.should == 0
    end

    it 'should report non-excepted name' do
      @config[LargeClass::EXCLUDE_KEY] = ['SmellMe']
      lc = LargeClass.new(@config)
      lc.examine(@ctx, @rpt).should == true
      @rpt.length.should == 1
    end
  end
end

describe LargeClass do
  it 'should not report empty class in another module' do
    'class Treetop::Runtime::SyntaxNode; end'.should_not reek
  end

  it 'should deal with :: scoped names' do
    element = ClassContext.create(StopContext.new, [:colon2, [:colon2, [:const, :Treetop], :Runtime], :SyntaxNode])
    element.num_methods.should == 0
  end
end
