require 'spec/reek/code_checks'
require 'reek/smells/feature_envy'

include CodeChecks
include Reek::Smells

describe FeatureEnvy, 'with only messages to self' do
  check 'should not report use of self',
    'def simple() self.to_s + self.to_i end', []
  check 'should not report vcall with no argument',
    'def simple() func; end', []
  check 'should not report vcall with argument',
    'def simple(arga) func(17); end', []
end

describe FeatureEnvy, 'when the receiver is a parameter' do
  check 'should not report single use',
    'def no_envy(arga) arga.barg(@item) end', []
  check 'should not report return value',
    'def no_envy(arga) arga.barg(@item); arga end', []
  check 'should report many calls to parameter',
    'def envy(arga) arga.b(arga) + arga.c(@fred) end', [[/arga/]]
end

describe FeatureEnvy, 'when there are many possible receivers' do
  check 'should report highest affinity',
    'def total_envy
      fred = @item
      total = 0
      total += fred.price
      total += fred.tax
      total *= 1.15
    end', [[/total/]]
  check 'should report multiple affinities',
    'def total_envy
      fred = @item
      total = 0
      total += fred.price
      total += fred.tax
    end', [[/fred/], [/total/]]
end

describe FeatureEnvy, 'when the receiver is external' do
  check 'should ignore global variables',
    'def no_envy() $s2.to_a; $s2[@item] end', []
  check 'should not report class methods',
    'def simple() self.class.new.flatten_merge(self) end', []
end

describe FeatureEnvy, 'when the receiver is an ivar' do
  check 'should not report single use of an ivar',
    'def no_envy() @item.to_a end', []
  check 'should not report returning an ivar',
    'def no_envy() @item.to_a; @item end', []
  check 'should not report ivar usage in a parameter',
    'def no_envy; @item.price + tax(@item) - savings(@item) end', []
  check 'should not be fooled by duplication',
    'def feed(thing); @cow.feed_to(thing.pig); @duck.feed_to(thing.pig); end',
    [[/Duplication/]]
  check 'should count local calls',
    'def feed(thing); cow.feed_to(thing.pig); duck.feed_to(thing.pig); end',
    [[/Duplication/]]
end

describe FeatureEnvy, 'when the receiver is an lvar' do
  check 'should not report single use of an lvar',
    'def no_envy() lv = @item; lv.to_a end', []
  check 'should not report returning an lvar',
    'def no_envy() lv = @item; lv.to_a; lv end', []
  check 'should report many calls to lvar',
    'def envy; lv = @item; lv.price + lv.tax end', [[/lv/]]
  check 'should not report lvar usage in a parameter',
    'def no_envy; lv = @item; lv.price + tax(lv) - savings(lv) end', []
end

require 'reek/method_context'
require 'reek/stop_context'

include Reek

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
