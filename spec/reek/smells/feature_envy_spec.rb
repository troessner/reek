require_relative '../../spec_helper'
require_lib 'reek/smells/feature_envy'

RSpec.describe Reek::Smells::FeatureEnvy do
  it 'reports the right values' do
    src = <<-EOS
      class Alpha
        def bravo(charlie)
          (charlie.delta - charlie.echo) * foxtrot
        end
      end
    EOS

    expect(src).to reek_of(:FeatureEnvy,
                           lines:   [3, 3],
                           context: 'Alpha#bravo',
                           message: 'refers to charlie more than self (maybe move it to another class?)',
                           source:  'string',
                           name:    'charlie')
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Alpha
        def bravo(charlie)
          (charlie.delta - charlie.echo) * foxtrot
        end

        def golf(hotel)
          (hotel.india + hotel.juliett) * kilo
        end
      end
    EOS

    expect(src).to reek_of(:FeatureEnvy,
                           lines: [3, 3],
                           name:  'charlie')
    expect(src).to reek_of(:FeatureEnvy,
                           lines: [7, 7],
                           name:  'hotel')
  end

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
      src = <<-EOS
        def envy(arga)
          arga.b(arga) + arga.c(@fred)
        end
      EOS

      expect(src).to reek_of(:FeatureEnvy, name: 'arga')
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
    src = <<-EOS
      def feed(thing)
        @cow.feed_to(thing.pig)
        @duck.feed_to(thing.pig)
      end
    EOS

    expect(src).to reek_only_of(:DuplicateMethodCall)
  end

  it 'should count local calls' do
    src = <<-EOS
      def feed(thing)
        cow.feed_to(thing.pig)
        duck.feed_to(thing.pig)
      end
    EOS

    expect(src).to reek_only_of(:DuplicateMethodCall)
  end

  it 'should report many calls to lvar' do
    src = <<-EOS
      def envy()
        lv = @item
        lv.price + lv.tax
      end
    EOS

    expect(src).to reek_only_of(:FeatureEnvy)
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
    src = <<-EOS
      def report
        unless @report
          @report = Report.new
          cf = SmellConfig.new
          cf = cf.load_local(@dir) if @dir
          ContextBuilder.new(@report, cf.smell_listeners).check_source(@source)
        end
        @report
      end
    EOS

    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'interprets << correctly' do
    src = <<-EOS
      def report_on(report)
        if @is_doubled
          report.record_doubled_smell(self)
        else
          report << self
        end
      end
    EOS

    expect(src).not_to reek_of(:FeatureEnvy)
  end
end
