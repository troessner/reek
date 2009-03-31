require File.dirname(__FILE__) + '/../../spec_helper.rb'
require 'reek/smells/feature_envy'
require 'reek/method_context'
require 'reek/stop_context'

include Reek
include Reek::Smells

describe FeatureEnvy, 'with only messages to self' do
  it 'should not report use of self' do
    'def simple() self.to_s + self.to_i end'.should_not reek
  end

  it 'should not report vcall with no argument' do
    'def simple() func; end'.should_not reek
  end

  it 'should not report vcall with argument' do
    'def simple(arga) func(17); end'.should_not reek
  end
end

describe FeatureEnvy, 'when the receiver is a parameter' do
  it 'should not report single use' do
    'def no_envy(arga) arga.barg(@item) end'.should_not reek
  end

  it 'should not report return value' do
    'def no_envy(arga) arga.barg(@item); arga end'.should_not reek
  end

  it 'should report many calls to parameter' do
    'def envy(arga) arga.b(arga) + arga.c(@fred) end'.should reek_only_of(:FeatureEnvy, /arga/)
  end
end

describe FeatureEnvy, 'when there are many possible receivers' do
  it 'should report highest affinity' do
    ruby = 'def total_envy
      fred = @item
      total = 0
      total += fred.price
      total += fred.tax
      total *= 1.15
    end'
    ruby.should reek_only_of(:FeatureEnvy, /total/)
  end

  it 'should report multiple affinities' do
    ruby = 'def total_envy
      fred = @item
      total = 0
      total += fred.price
      total += fred.tax
    end'
    ruby.should reek_of(:FeatureEnvy, /total/)
    ruby.should reek_of(:FeatureEnvy, /fred/)
  end
end

describe FeatureEnvy, 'when the receiver is external' do
  it 'should ignore global variables' do
    'def no_envy() $s2.to_a; $s2[@item] end'.should_not reek
  end

  it 'should not report class methods' do
    'def simple() self.class.new.flatten_merge(self) end'.should_not reek
  end
end

describe FeatureEnvy, 'when the receiver is an ivar' do
  it 'should not report single use of an ivar' do
    'def no_envy() @item.to_a end'.should_not reek
  end

  it 'should not report returning an ivar' do
    'def no_envy() @item.to_a; @item end'.should_not reek
  end

  it 'should not report ivar usage in a parameter' do
    'def no_envy; @item.price + tax(@item) - savings(@item) end'.should_not reek
  end

  it 'should not be fooled by duplication' do
    ruby = Source.from_s('def feed(thing); @cow.feed_to(thing.pig); @duck.feed_to(thing.pig); end')
    ruby.should reek_only_of(:Duplication, /thing.pig/)
  end

  it 'should count local calls' do
    ruby = Source.from_s('def feed(thing); cow.feed_to(thing.pig); duck.feed_to(thing.pig); end')
    ruby.should reek_only_of(:Duplication, /thing.pig/)
  end
end

describe FeatureEnvy, '#examine' do

  before :each do
    @context = MethodContext.new(StopContext.new, [:defn, :cool])
    @fe = FeatureEnvy.new
  end

  it 'should return true when reporting a smell' do
    @context.refs.record_ref([:lvar, :thing])
    @context.refs.record_ref([:lvar, :thing])
    @fe.examine(@context, []).should == true
  end
  
  it 'should return false when not reporting a smell' do
    @fe.examine(@context, []).should == false
  end
end

describe FeatureEnvy, 'when the receiver is an lvar' do
  it 'should not report single use of an lvar' do
    'def no_envy() lv = @item; lv.to_a end'.should_not reek
  end

  it 'should not report returning an lvar' do
    'def no_envy() lv = @item; lv.to_a; lv end'.should_not reek
  end

  it 'should report many calls to lvar' do
    'def envy; lv = @item; lv.price + lv.tax end'.should reek_only_of(:FeatureEnvy, /lv/)
  end

  it 'should not report lvar usage in a parameter' do
    'def no_envy; lv = @item; lv.price + tax(lv) - savings(lv) end'.should_not reek
  end
end
