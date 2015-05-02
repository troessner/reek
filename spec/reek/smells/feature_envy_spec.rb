require_relative '../../spec_helper'
require_relative '../../../lib/reek/smells/feature_envy'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::FeatureEnvy do
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
      src = <<-EOS
        def func
          @other.a
          @other.b
          @nother.c
          @nother.d
        end
      EOS
      expect(src).not_to reek_of(:FeatureEnvy)
    end
  end

  context 'with 2 calls to a parameter' do
    it 'reports the smell' do
      expect('
        def envy(arga)
          arga.b(arga) + arga.c(@fred)
        end
      ').to reek_of(:FeatureEnvy, name: 'arga')
    end
  end

  it 'should report highest affinity' do
    src = <<-EOS
      def total_envy
        fred = @item
        total = 0
        total += fred.price
        total += fred.tax
        total *= 1.15
      end
      EOS
    expect(src).to reek_of(:FeatureEnvy, name: 'total')
    expect(src).not_to reek_of(:FeatureEnvy, name: 'fred')
  end

  it 'should report multiple affinities' do
    src = <<-EOS
      def total_envy
        fred = @item
        total = 0
        total += fred.price
        total += fred.tax
      end
      EOS
    expect(src).to reek_of(:FeatureEnvy, name: 'total')
    expect(src).to reek_of(:FeatureEnvy, name: 'fred')
  end

  it 'should not be fooled by duplication' do
    expect('
      def feed(thing)
        @cow.feed_to(thing.pig)
        @duck.feed_to(thing.pig)
      end
    ').to reek_only_of(:Duplication)
  end

  it 'should count local calls' do
    expect('
      def feed(thing)
        cow.feed_to(thing.pig)
        duck.feed_to(thing.pig)
      end
    ').to reek_only_of(:Duplication)
  end

  it 'should report many calls to lvar' do
    expect('
      def envy()
        lv = @item
        lv.price + lv.tax
      end
    ').to reek_only_of(:FeatureEnvy)
  end

  it 'ignores frequent use of a call' do
    expect('def func() other.a; other.b; nother.c end').not_to reek_of(:FeatureEnvy)
  end

  it 'counts =~ as a call' do
    src = <<-EOS
    def foo arg
      bar(arg.baz)
      arg =~ /bar/
    end
    EOS
    expect(src).to reek_of :FeatureEnvy
  end

  it 'counts += as a call' do
    src = <<-EOS
    def foo arg
      bar(arg.baz)
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
    src = <<-EOS
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

  it 'counts references to self correctly' do
    ruby = <<-EOS
      def report
        unless @report
          @report = Report.new
          cf = SmellConfig.new
          cf = cf.load_local(@dir) if @dir
          TreeWalker.new(@report, cf.smell_listeners).check_source(@source)
        end
        @report
      end
    EOS
    expect(ruby).not_to reek_of(:FeatureEnvy)
  end

  it 'interprets << correctly' do
    ruby = <<-EOS
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

RSpec.describe Reek::Smells::FeatureEnvy do
  before(:each) do
    @source_name = 'dummy_source'
    @detector = build(:smell_detector, smell_type: :FeatureEnvy, source: @source_name)
  end

  it_should_behave_like 'SmellDetector'

  context 'when reporting yaml' do
    before :each do
      @receiver = 'other'
      src = <<-EOS
        def envious(other)
          #{@receiver}.call
          self.do_nothing
          #{@receiver}.other
          #{@receiver}.fred
        end
      EOS
      source = Reek::Source::SourceCode.from(src)
      @mctx = Reek::Core::TreeWalker.new.process_def(source.syntax_tree)
      @smells = @detector.examine_context(@mctx)
    end

    it 'reports only that smell' do
      expect(@smells.length).to eq(1)
    end

    it 'reports the source' do
      expect(@smells[0].source).to eq(@source_name)
    end

    it 'reports the smell class' do
      expect(@smells[0].smell_category).to eq(described_class.smell_category)
    end

    it 'reports the smell sub class' do
      expect(@smells[0].smell_type).to eq(described_class.smell_type)
    end

    it 'reports the envious receiver' do
      expect(@smells[0].parameters[:name]).to eq(@receiver)
    end

    it 'reports the number of references' do
      expect(@smells[0].parameters[:count]).to eq(3)
    end

    it 'reports the referring lines' do
      skip
      expect(@smells[0].lines).to eq([2, 4, 5])
    end
  end
end
