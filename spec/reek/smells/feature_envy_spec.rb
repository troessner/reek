require 'spec_helper'
require 'reek/smells/feature_envy'
require 'reek/smells/smell_detector_shared'

include Reek
include Reek::Smells

describe FeatureEnvy do
  context 'with no smell' do
    it 'should not report use of self' do
      expect('def simple() self.to_s + self.to_i end').not_to reek_of(:FeatureEnvy)
    end
    it 'should not report vcall with no argument' do
      expect('def simple() func; end').not_to reek_of(:FeatureEnvy)
    end
    it 'should not report single use' do
      expect('def no_envy(arga) arga.barg(@item) end').not_to reek_of(:FeatureEnvy)
    end
    it 'should not report return value' do
      expect('def no_envy(arga) arga.barg(@item); arga end').not_to reek_of(:FeatureEnvy)
    end
    it 'should ignore global variables' do
      expect('def no_envy() $s2.to_a; $s2[@item] end').not_to reek_of(:FeatureEnvy)
    end
    it 'should not report class methods' do
      expect('def simple() self.class.new.flatten_merge(self) end').
        not_to reek_of(:FeatureEnvy)
    end
    it 'should not report single use of an ivar' do
      expect('def no_envy() @item.to_a end').not_to reek_of(:FeatureEnvy)
    end
    it 'should not report returning an ivar' do
      expect('def no_envy() @item.to_a; @item end').not_to reek_of(:FeatureEnvy)
    end
    it 'should not report ivar usage in a parameter' do
      expect('def no_envy() @item.price + tax(@item) - savings(@item) end').
        not_to reek_of(:FeatureEnvy)
    end
    it 'should not report single use of an lvar' do
      expect('def no_envy() lv = @item; lv.to_a end').not_to reek_of(:FeatureEnvy)
    end
    it 'should not report returning an lvar' do
      expect('def no_envy() lv = @item; lv.to_a; lv end').not_to reek_of(:FeatureEnvy)
    end
    it 'ignores lvar usage in a parameter' do
      expect('def no_envy() lv = @item; lv.price + tax(lv) - savings(lv); end').
        not_to reek_of(:FeatureEnvy)
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
      expect(src).not_to reek_of(:FeatureEnvy)
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
      expect('def envy(arga) arga.b(arga) + arga.c(@fred) end').to reek_only_of(:FeatureEnvy, /arga/)
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
    expect(src).to reek_only_of(:FeatureEnvy, /total/)
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
    expect(src).to reek_of(:FeatureEnvy, /total/)
    expect(src).to reek_of(:FeatureEnvy, /fred/)
  end

  it 'should not be fooled by duplication' do
    expect('def feed(thing) @cow.feed_to(thing.pig); @duck.feed_to(thing.pig) end').to reek_only_of(:Duplication, /thing.pig/)
  end

  it 'should count local calls' do
    expect('def feed(thing) cow.feed_to(thing.pig); duck.feed_to(thing.pig) end').to reek_only_of(:Duplication, /thing.pig/)
  end

  it 'should report many calls to lvar' do
    expect('def envy() lv = @item; lv.price + lv.tax; end').to reek_only_of(:FeatureEnvy, /lv/)
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
    expect('def func() other.a; other.b; nother.c end').not_to reek_of(:FeatureEnvy)
  end

  it 'counts =~ as a call' do
    src = <<-EOS
    def foo arg
      arg =~ /bar/
    end
    EOS
    expect(src).to reek_of :FeatureEnvy
  end

  it 'counts += as a call' do
    src = <<-EOS
    def foo arg
      arg += 1
    end
    EOS
    expect(src).to reek_of :FeatureEnvy
  end

  it 'counts ivar assignment as call to self' do
    src = <<-EOS
    def foo
      bar = baz(1, 2)

      @quuz = bar.qux
      @zyxy = bar.foobar
    end
    EOS
    expect(src).not_to reek_of :FeatureEnvy
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
    expect(src).not_to reek_of(:FeatureEnvy)
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
    expect(ruby).not_to reek_of(:FeatureEnvy)
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

    expect(ruby).not_to reek_of(:FeatureEnvy)
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
      @mctx = CodeParser.new(sniffer).process_def(source.syntax_tree)
      @smells = @detector.examine_context(@mctx)
    end
    it 'reports only that smell' do
      expect(@smells.length).to eq(1)
    end
    it 'reports the source' do
      expect(@smells[0].source).to eq(@source_name)
    end
    it 'reports the class' do
      expect(@smells[0].smell_class).to eq(FeatureEnvy::SMELL_CLASS)
    end
    it 'reports the subclass' do
      expect(@smells[0].smell_sub_class).to eq(FeatureEnvy::SMELL_SUBCLASS)
    end
    it 'reports the envious receiver' do
      expect(@smells[0].smell[FeatureEnvy::RECEIVER_KEY]).to eq(@receiver)
    end
    it 'reports the number of references' do
      expect(@smells[0].smell[FeatureEnvy::REFERENCES_KEY]).to eq(3)
    end
    it 'reports the referring lines' do
      skip
      expect(@smells[0].lines).to eq([2, 4, 5])
    end
  end
end
