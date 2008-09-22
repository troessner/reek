require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'reek/method_checker'
require 'reek/smells'
require 'reek/report'

include Reek

describe FeatureEnvy, 'with only messages to self' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report use of self' do
    @cchk.check_source('def simple() self.to_s + self.to_i end')
    @rpt.should be_empty
  end

  it 'should not report vcall with no argument' do
    @cchk.check_source('def simple() func + grunc end')
    @rpt.should be_empty
  end

  it 'should not report vcall with argument' do
    @cchk.check_source('def simple(arga) func(17) + grunc(arga) end')
    @rpt.should be_empty
  end
end

describe FeatureEnvy, 'when the receiver is a parameter' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report single use' do
    @cchk.check_source('def no_envy(arga) arga.barg(@item) end')
    @rpt.length.should == 0
  end

  it 'should not report return value' do
    @cchk.check_source('def no_envy(arga) arga.barg(@item); arga end')
    @rpt.length.should == 0
  end

  it 'should report many calls to parameter' do
    @cchk.check_source('def envy(arga) arga.b(arga) + arga.c(@fred) end')
    @rpt.length.should == 1
    FeatureEnvy.should === @rpt[0]
    @rpt[0].to_s.should match(/arga/)
  end
end

describe FeatureEnvy, 'when there are many possible receivers' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should report highest affinity' do
    @cchk.check_source('def total_envy() @total += @item.price; @total += @item.tax; @total *= 1.15 end')
    @rpt.length.should == 1
    FeatureEnvy.should === @rpt[0]
    @rpt[0].to_s.should match(/@total/)
  end

  it 'should report multiple affinities' do
    @cchk.check_source('def total_envy() @total += @item.price; @total += @item.tax end')
    @rpt.length.should == 1
    @rpt[0].to_s.should match(/@total/)
    @rpt[0].to_s.should match(/@item/)
  end
end

describe FeatureEnvy, 'when the receiver is external' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should ignore global variables' do
    @cchk.check_source('def no_envy() $s2.to_a; $s2[@item] end')
    @rpt.should be_empty
  end

  it 'should not report class methods' do
    @cchk.check_source('def simple() self.class.new.flatten_merge(self) end')
    @rpt.should be_empty
  end
end

describe FeatureEnvy, 'when the receiver is an ivar' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report single use of an ivar' do
    @cchk.check_source('def no_envy() @item.to_a end')
    @rpt.length.should == 0
  end

  it 'should not report returning an ivar' do
    @cchk.check_source('def no_envy() @item.to_a; @item end')
    @rpt.length.should == 0
  end

  it 'should report many calls to ivar' do
    @cchk.check_source('def envy; @item.price + @item.tax end')
    @rpt.length.should == 1
    FeatureEnvy.should === @rpt[0]
    @rpt[0].to_s.should match(/@item/)
  end

  it 'should not report ivar usage in a parameter' do
    @cchk.check_source('def no_envy; @item.price + tax(@item) - savings(@item) end')
    @rpt.should be_empty
  end
end

describe FeatureEnvy, 'when the receiver is an lvar' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report single use of an lvar' do
    @cchk.check_source('def no_envy() lv = @item; lv.to_a end')
    @rpt.length.should == 0
  end

  it 'should not report returning an lvar' do
    @cchk.check_source('def no_envy() lv = @item; lv.to_a; lv end')
    @rpt.length.should == 0
  end

  it 'should report many calls to lvar' do
    @cchk.check_source('def envy; lv = @item; lv.price + lv.tax end')
    @rpt.length.should == 1
    FeatureEnvy.should === @rpt[0]
    @rpt[0].to_s.should match(/lv/)
  end

  it 'should not report lvar usage in a parameter' do
    @cchk.check_source('def no_envy; lv = @item; lv.price + tax(lv) - savings(lv) end')
    @rpt.should be_empty
  end
end

describe FeatureEnvy, 'when the receiver is a returned value' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it 'should not report single use of a return value' do
    @cchk.check_source('def no_envy() f.g.price end')
    @rpt.length.should == 0
  end

  it 'should not report return value' do
    @cchk.check_source('def no_envy() f.g.wibble; f.g end')
    @rpt.length.should == 1
    FeatureEnvy.should === @rpt[0]
    @rpt[0].to_s.should match(/f/)
    @rpt[0].to_s.should_not match(/f.g/)
  end

  it 'should report many calls to a returned value' do
    @cchk.check_source('def envy; f.g.price + f.g.tax end')
    @rpt.length.should == 1
    FeatureEnvy.should === @rpt[0]
    @rpt[0].to_s.should match(/f.g/)
  end

  it 'should not report value usage in a parameter' do
    @cchk.check_source('def no_envy; f.g.price + tax(f.g) - savings(f.g) end')
    @rpt.should be_empty
  end
end

describe FeatureEnvy, 'when the receiver is a dvar' do
  before(:each) do
    @rpt = Report.new
    @cchk = MethodChecker.new(@rpt, 'Thing')
  end

  it "should not report method with successive iterators" do
    pending('this is a bug!')
    source =<<EOS
def bad(fred)
  @fred.each {|item| item.each }
  @jim.each {|item| item.each }
end
EOS
    @chk.check_source(source)
    @rpt.should be_empty
  end  
end
