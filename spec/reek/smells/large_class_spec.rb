require File.dirname(__FILE__) + '/../../spec_helper.rb'
require 'reek/code_parser'
require 'reek/report'
require 'reek/smells/large_class'

include Reek
include Reek::Smells

describe LargeClass do

  it 'should report large class' do
    class BigOne
      26.times do |i|
        define_method "method#{i}".to_sym do
          @melting
        end
      end
    end
    BigOne.should reek_only_of(:LargeClass, /BigOne/)
  end
end

describe LargeClass do

  it 'should not report short class' do
    class ShortClass
      def method1() @var1; end
      def method2() @var2; end
      def method3() @var3; end
      def method4() @var4; end
      def method5() @var5; end
      def method6() @var6; end
    end
    ShortClass.should_not reek
  end
end

describe LargeClass, 'when exceptions are listed' do

  before(:each) do
    @rpt = Report.new
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

describe LargeClass, 'counting instance variables' do
  it 'warns about class with 10 ivars' do
    class ManyIvars
      def method
        @vara = @varb = @varc = @vard = @vare
        @varf = @varg = @varh = @vari = @varj
      end
    end
    ManyIvars.should reek_of(:LargeClass, /10/)
  end

  it 'ignores class with only a couple of ivars' do
    LargeClass.should_not reek_of(:LargeClass)
  end

  it 'ignores fq class with only a couple of ivars' do
    Reek::Smells::LargeClass.should_not reek_of(:LargeClass)
  end
end
