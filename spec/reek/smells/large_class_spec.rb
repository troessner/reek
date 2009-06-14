require File.dirname(__FILE__) + '/../../spec_helper.rb'
require 'reek/code_parser'
require 'reek/report'
require 'reek/smells/large_class'

include Reek
include Reek::Smells

describe LargeClass, 'checking Class objects' do

  it 'should not report class with 26 methods' do
    class BigOne
      26.times do |i|
        define_method "method#{i}".to_sym do
          @melting
        end
      end
    end
    BigOne.should_not reek
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
    ShortClass.should_not reek
  end

  describe LargeClass, 'counting instance variables' do
    it 'should not report class with 10 ivars' do
      class ManyIvars
        def method
          @vara = @varb = @varc = @vard = @vare
          @varf = @varg = @varh = @vari = @varj
        end
      end
      ManyIvars.should_not reek
    end

    it 'ignores class with only a couple of ivars' do
      LargeClass.should_not reek_of(:LargeClass)
    end

    it 'ignores fq class with only a couple of ivars' do
      Reek::Smells::LargeClass.should_not reek_of(:LargeClass)
    end
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
    lc.report_on(@rpt)
    @rpt.length.should == 0
  end

  it 'should ignore second excepted name' do
    @config[LargeClass::EXCLUDE_KEY] = ['Oversized', 'Humungous']
    lc = LargeClass.new(@config)
    lc.examine(@ctx, @rpt).should == false
    lc.report_on(@rpt)
    @rpt.length.should == 0
  end

  it 'should report non-excepted name' do
    @config[LargeClass::EXCLUDE_KEY] = ['SmellMe']
    lc = LargeClass.new(@config)
    lc.examine(@ctx, @rpt).should == true
    lc.report_on(@rpt)
    @rpt.length.should == 1
  end
end

describe LargeClass, 'checking source code' do

  describe 'counting instance variables' do
    it 'should not report empty class' do
      ClassContext.from_s('class Empty;end').should have(0).variable_names
    end

    it 'should count ivars in one method' do
      ClassContext.from_s('class Empty;def ivars() @aa=@ab=@ac=@ad; end;end').should have(4).variable_names
    end

    it 'should count ivars in 2 methods' do
      ClassContext.from_s('class Empty;def iv1() @aa=@ab; end;def iv2() @aa=@ac; end;end').should have(3).variable_names
    end

    it 'should not report 9 ivars' do
      'class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai; end;end'.should_not reek
    end

    it 'should report 10 ivars' do
      'class Empty;def ivars() @aa=@ab=@ac=@ad=@ae=@af=@ag=@ah=@ai=@aj; end;end'.should reek_of(:LargeClass)
    end

    it 'should not report 10 ivars in 2 extensions' do
      src = <<EOS
class Full;def ivars1() @aa=@ab=@ac=@ad=@ae; end;end
class Full;def ivars2() @af=@ag=@ah=@ai=@aj; end;end
EOS
      src.should_not reek
    end
  end

  describe 'counting methods' do
    it 'should not report empty class' do
      ClassContext.from_s('class Empty;end').num_methods.should == 0
    end

    it 'should count 1 method' do
      ClassContext.from_s('class Empty;def ivars() @aa=@ab; end;end').num_methods.should == 1
    end

    it 'should count 2 methods' do
      ClassContext.from_s('class Empty;def meth1() @aa=@ab;end;def meth2() @aa=@ab;end;end').num_methods.should == 2
    end

    it 'should not report 25 methods' do
      src = <<EOS
class Full
  def me01()3 end;def me02()3 end;def me03()3 end;def me04()3 end;def me05()3 end
  def me11()3 end;def me12()3 end;def me13()3 end;def me14()3 end;def me15()3 end
  def me21()3 end;def me22()3 end;def me23()3 end;def me24()3 end;def me25()3 end
  def me31()3 end;def me32()3 end;def me33()3 end;def me34()3 end;def me35()3 end
  def me41()3 end;def me42()3 end;def me43()3 end;def me44()3 end;def me45()3 end
end
EOS
      src.should_not reek
    end

    it 'should report 26 methods' do
      src = <<EOS
class Full
  def me01()3 end;def me02()3 end;def me03()3 end;def me04()3 end;def me05()3 end
  def me11()3 end;def me12()3 end;def me13()3 end;def me14()3 end;def me15()3 end
  def me21()3 end;def me22()3 end;def me23()3 end;def me24()3 end;def me25()3 end
  def me31()3 end;def me32()3 end;def me33()3 end;def me34()3 end;def me35()3 end
  def me41()3 end;def me42()3 end;def me43()3 end;def me44()3 end;def me45()3 end
  def me51()3 end
end
EOS
      src.should reek_of(:LargeClass)
    end
  end
end
