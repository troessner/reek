require 'spec_helper'
require 'reek/smells/feature_envy'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe FeatureEnvy do
  context 'with no smell' do
    it 'should not report use of self' do
      'def simple() self.to_s + self.to_i end'.should_not reek
    end
    it 'should not report vcall with no argument' do
      'def simple() func; end'.should_not reek
    end
    it 'should not report single use' do
      'def no_envy(arga) arga.barg(@item) end'.should_not reek
    end
    it 'should not report return value' do
      'def no_envy(arga) arga.barg(@item); arga end'.should_not reek
    end
    it 'should ignore global variables' do
      'def no_envy() $s2.to_a; $s2[@item] end'.should_not reek
    end
    it 'should not report class methods' do
      'def simple() self.class.new.flatten_merge(self) end'.should_not reek
    end
    it 'should not report single use of an ivar' do
      'def no_envy() @item.to_a end'.should_not reek
    end
    it 'should not report returning an ivar' do
      'def no_envy() @item.to_a; @item end'.should_not reek
    end
    it 'should not report ivar usage in a parameter' do
      'def no_envy() @item.price + tax(@item) - savings(@item) end'.should_not reek
    end
    it 'should not report single use of an lvar' do
      'def no_envy() lv = @item; lv.to_a end'.should_not reek
    end
    it 'should not report returning an lvar' do
      'def no_envy() lv = @item; lv.to_a; lv end'.should_not reek
    end
    it 'ignores lvar usage in a parameter' do
      'def no_envy() lv = @item; lv.price + tax(lv) - savings(lv); end'.should_not reek
    end
    it 'ignores multiple ivars' do
      src = <<EOS
  def func
    @other.a
    @other.b
    @nother.c
    @nother.d
  end
EOS
      src.should_not reek
      #
      # def other.func(me)
      #   a
      #   b
      #   me.nother_c
      #   me.nother_d
      # end
      #
    end
  end

  context 'with 2 calls to a parameter' do
    it 'reports the smell' do
      'def envy(arga) arga.b(arga) + arga.c(@fred) end'.should reek_only_of(:FeatureEnvy, /arga/)
    end
  end

  it 'should report highest affinity' do
    src = <<EOS
def total_envy
  fred = @item
  total = 0
  total += fred.price
  total += fred.tax
  total *= 1.15
end
EOS
    src.should reek_only_of(:FeatureEnvy, /total/)
  end

  it 'should report multiple affinities' do
    src = <<EOS
def total_envy
  fred = @item
  total = 0
  total += fred.price
  total += fred.tax
end
EOS
    src.should reek_of(:FeatureEnvy, /total/)
    src.should reek_of(:FeatureEnvy, /fred/)
  end

  it 'should not be fooled by duplication' do
    'def feed(thing) @cow.feed_to(thing.pig); @duck.feed_to(thing.pig) end'.should reek_only_of(:Duplication, /thing.pig/)
  end

  it 'should count local calls' do
    'def feed(thing) cow.feed_to(thing.pig); duck.feed_to(thing.pig) end'.should reek_only_of(:Duplication, /thing.pig/)
  end

  it 'should report many calls to lvar' do
    'def envy() lv = @item; lv.price + lv.tax; end'.should reek_only_of(:FeatureEnvy, /lv/)
    #
    # def moved_version
    #   price + tax
    # end
    #
    # def envy
    #   @item.moved_version
    # end
  end

  it 'ignores frequent use of a call' do
    'def func() other.a; other.b; nother.c end'.should_not reek_of(:FeatureEnvy)
  end

  it 'counts self references correctly' do
    src = <<EOS
def adopt(other)
  other.keys.each do |key|
    self[key] += 3
    self[key] = o4
  end
  self
end
EOS
    src.should_not reek
  end
end

describe FeatureEnvy do
  it 'counts references to self correctly' do
    ruby = <<EOS
def report
  unless @report
    @report = Report.new
    cf = SmellConfig.new
    cf = cf.load_local(@dir) if @dir
    CodeParser.new(@report, cf.smell_listeners).check_source(@source)
  end
  @report
end
EOS
    ruby.should_not reek
  end

  it 'interprets << correctly' do
    ruby = <<EOS
def report_on(report)
  if @is_doubled
    report.record_doubled_smell(self)
  else
    report << self
  end
end
EOS

    ruby.should_not reek
  end
end

describe FeatureEnvy do
  before(:each) do
    @source_name = 'green as a cucumber'
    @detector = FeatureEnvy.new(@source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'when reporting yaml' do
    before :each do
      @receiver = 'other'
      src = <<EOS
def envious(other)
  #{@receiver}.call
  self.do_nothing
  #{@receiver}.other
  #{@receiver}.fred
end
EOS
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      @mctx = CodeParser.new(sniffer).process_defn(source.syntax_tree)
      @smells = @detector.examine_context(@mctx)
    end
    it 'reports only that smell' do
      @smells.length.should == 1
    end
    it 'reports the source' do
      @smells[0].source.should == @source_name
    end
    it 'reports the class' do
      @smells[0].smell_class.should == FeatureEnvy::SMELL_CLASS
    end
    it 'reports the subclass' do
      @smells[0].subclass.should == FeatureEnvy::SMELL_SUBCLASS
    end
    it 'reports the envious receiver' do
      @smells[0].smell[FeatureEnvy::RECEIVER_KEY].should == @receiver
    end
    it 'reports the number of references' do
      @smells[0].smell[FeatureEnvy::REFERENCES_KEY].should == 3
    end
    it 'reports the referring lines' do
      pending
      @smells[0].lines.should == [2, 4, 5]
    end
  end
end
