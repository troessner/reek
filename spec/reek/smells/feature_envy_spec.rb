require 'spec/reek/code_checks'
require 'reek/smells/feature_envy'

require 'reek/method_context'
require 'reek/stop_context'

include Reek
include CodeChecks
include Reek::Smells

class String
  def to_source
    Source.from_s(self)
  end
end

class ShouldSmell
  def matches?(actual)
    @source = actual.to_source
    @source.smelly?
  end
  def failure_message_for_should
    "Expected source to smell, but it didn't"
  end
  def failure_message_for_should_not
    "Expected no smells, but got the following:\n#{@source.report}"
  end
end

def smell
  ShouldSmell.new
end

class ShouldSmellOf
  def initialize(klass, patterns)
    @klass = klass
    @patterns = patterns
  end
  def matches?(actual)
    @source = actual.to_source
    @source.has_smell?(@klass, @patterns)
  end
  def failure_message_for_should
    "Expected source to smell of #{@klass}, but it didn't"
  end
  def failure_message_for_should_not
    "Expected source not to smell of #{@klass}, but got the following:\n#{@source.report}"
  end
end

def smell_of(klass, *patterns)
  ShouldSmellOf.new(klass, patterns)
end

#-------------------------------------------------------------------------------------------

describe FeatureEnvy, 'with only messages to self' do
  it 'should not report use of self' do
    'def simple() self.to_s + self.to_i end'.should_not smell
  end

  it 'should not report vcall with no argument' do
    'def simple() func; end'.should_not smell
  end

  it 'should not report vcall with argument' do
    'def simple(arga) func(17); end'.should_not smell
  end
end

describe FeatureEnvy, 'when the receiver is a parameter' do
  it 'should not report single use' do
    'def no_envy(arga) arga.barg(@item) end'.should_not smell
  end

  it 'should not report return value' do
    'def no_envy(arga) arga.barg(@item); arga end'.should_not smell
  end

  it 'should report many calls to parameter' do
    'def envy(arga) arga.b(arga) + arga.c(@fred) end'.should smell_of(:FeatureEnvy, /arga/)
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
    ruby.should smell_of(:FeatureEnvy, /total/)
    ruby.should_not smell_of(:FeatureEnvy, /fred/)
  end

  it 'should report multiple affinities' do
    ruby = 'def total_envy
      fred = @item
      total = 0
      total += fred.price
      total += fred.tax
    end'
    ruby.should smell_of(:FeatureEnvy, /total/)
    ruby.should smell_of(:FeatureEnvy, /fred/)
  end
end

describe FeatureEnvy, 'when the receiver is external' do
  it 'should ignore global variables' do
    'def no_envy() $s2.to_a; $s2[@item] end'.should_not smell
  end

  it 'should not report class methods' do
    'def simple() self.class.new.flatten_merge(self) end'.should_not smell
  end
end

describe FeatureEnvy, 'when the receiver is an ivar' do
  it 'should not report single use of an ivar' do
    'def no_envy() @item.to_a end'.should_not smell
  end

  it 'should not report returning an ivar' do
    'def no_envy() @item.to_a; @item end'.should_not smell
  end

  it 'should not report ivar usage in a parameter' do
    'def no_envy; @item.price + tax(@item) - savings(@item) end'.should_not smell
  end

  it 'should not be fooled by duplication' do
    'def feed(thing); @cow.feed_to(thing.pig); @duck.feed_to(thing.pig); end'.should_not smell_of(:FeatureEnvy)
  end
  it 'should count local calls' do
    'def feed(thing); cow.feed_to(thing.pig); duck.feed_to(thing.pig); end'.should_not smell_of(:FeatureEnvy)
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
    'def no_envy() lv = @item; lv.to_a end'.should_not smell
  end

  it 'should not report returning an lvar' do
    'def no_envy() lv = @item; lv.to_a; lv end'.should_not smell
  end

  it 'should report many calls to lvar' do
    'def envy; lv = @item; lv.price + lv.tax end'.should smell_of(:FeatureEnvy, /lv/)
  end

  it 'should not report lvar usage in a parameter' do
    'def no_envy; lv = @item; lv.price + tax(lv) - savings(lv) end'.should_not smell
  end
end
