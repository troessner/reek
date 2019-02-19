require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/feature_envy'

RSpec.describe Reek::SmellDetectors::FeatureEnvy do
  it 'reports the right values' do
    src = <<-RUBY
      class Alfa
        def bravo(charlie)
          (charlie.delta - charlie.echo) * foxtrot
        end
      end
    RUBY

    expect(src).to reek_of(:FeatureEnvy,
                           lines:   [3, 3],
                           context: 'Alfa#bravo',
                           message: "refers to 'charlie' more than self (maybe move it to another class?)",
                           source:  'string',
                           name:    'charlie')
  end

  it 'does count all occurences' do
    src = <<-RUBY
      class Alfa
        def bravo(charlie)
          (charlie.delta - charlie.echo) * foxtrot
        end

        def golf(hotel)
          (hotel.india + hotel.juliett) * kilo
        end
      end
    RUBY

    expect(src).
      to reek_of(:FeatureEnvy, lines: [3, 3], name: 'charlie').
      and reek_of(:FeatureEnvy, lines: [7, 7], name: 'hotel')
  end

  it 'does not report use of self' do
    src = 'def alfa; self.to_s + self.to_i; end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report vcall with no argument' do
    src = 'def alfa; bravo; end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report single use' do
    src = 'def alfa(bravo); bravo.charlie(@delta); end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report return value' do
    src = 'def alfa(bravo); bravo.charlie(@delta); bravo; end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does ignore global variables' do
    src = 'def alfa; $bravo.to_a; $bravo[@charlie]; end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report class methods' do
    src = 'def alfa; self.class.bravo(self); end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report single use of an ivar' do
    src = 'def alfa; @bravo.to_a; end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report returning an ivar' do
    src = 'def alfa; @bravo.to_a; @bravo; end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report ivar usage in a parameter' do
    src = 'def alfa; @bravo.charlie + delta(@bravo) - echo(@bravo) end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report single use of an lvar' do
    src = 'def alfa; bravo = @charlie; bravo.to_a; end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report returning an lvar' do
    src = 'def alfa; bravo = @charlie; bravo.to_a; lv end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'ignores lvar usage in a parameter' do
    src = 'def alfa; bravo = @item; bravo.charlie + delta(bravo) - echo(bravo); end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report parameter method called with super' do
    src = 'def alfa(bravo) super(bravo.to_s); end'
    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'reports parameter method called with super and elsewhere' do
    src = 'def alfa(bravo) bravo.charley; super(bravo.to_s); end'
    expect(src).to reek_of(:FeatureEnvy)
  end

  it 'ignores multiple ivars' do
    src = <<-RUBY
      def func
        @alfa.charlie
        @alfa.delta

        @bravo.echo
        @bravo.foxtrot
      end
    RUBY

    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'report highest affinity' do
    src = <<-RUBY
      def alfa
        bravo = @charlie
        delta = 0
        delta += bravo.echo
        delta += bravo.foxtrot
        delta *= 1.15
      end
    RUBY

    expect(src).
      to reek_of(:FeatureEnvy, name: 'delta').
      and not_reek_of(:FeatureEnvy, name: 'bravo')
  end

  it 'reports multiple affinities' do
    src = <<-RUBY
      def alfa
        bravo = @charlie
        delta = 0
        delta += bravo.echo
        delta += bravo.foxtrot
      end
    RUBY

    expect(src).
      to reek_of(:FeatureEnvy, name: 'delta').
      and reek_of(:FeatureEnvy, name: 'bravo')
  end

  it 'is not fooled by duplication' do
    src = <<-RUBY
      def alfa(bravo)
        @charlie.delta(bravo.echo)
        @foxtrot.delta(bravo.echo)
      end
    RUBY

    expect(src).to reek_only_of(:DuplicateMethodCall, name: 'bravo.echo')
  end

  it 'counts local calls' do
    src = <<-RUBY
      def alfa(bravo)
        charlie.delta(bravo.echo)
        foxtrot.delta(bravo.echo)
      end
    RUBY

    expect(src).to reek_only_of(:DuplicateMethodCall, name: 'bravo.echo')
  end

  it 'reports many calls to lvar' do
    src = <<-RUBY
      def alfa
        bravo = @charlie
        bravo.delta + bravo.echo
      end
    RUBY

    expect(src).to reek_only_of(:FeatureEnvy)
  end

  it 'counts =~ as a call' do
    src = <<-RUBY
      def alfa(bravo)
        charlie(bravo.delta)
        bravo =~ /charlie/
      end
    RUBY

    expect(src).to reek_of :FeatureEnvy
  end

  it 'counts += as a call' do
    src = <<-RUBY
      def alfa(bravo)
        charlie(bravo.delta)
        bravo += 1
      end
    RUBY

    expect(src).to reek_of :FeatureEnvy
  end

  it 'counts ivar assignment as call to self' do
    src = <<-RUBY
      def foo
        bravo = charlie(1, 2)

        @delta = bravo.echo
        @foxtrot = bravo.golf
      end
    RUBY

    expect(src).not_to reek_of :FeatureEnvy
  end

  it 'counts self references correctly' do
    src = <<-RUBY
      def alfa(bravo)
        bravo.keys.each do |charlie|
          self[charlie] += 3
          self[charlie] = 4
        end
        self
      end
    RUBY

    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'interprets << correctly' do
    src = <<-RUBY
      def alfa(bravo)
        if @charlie
          bravo.delta(self)
        else
          bravo << self
        end
      end
    RUBY

    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report on class methods defined by opening the metaclass' do
    src = <<-RUBY
      class Alfa
        class << self
          def bravo(charlie)
            delta = new(charlie)
            delta.echo
            delta.echo
          end
        end
      end
    RUBY

    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report on class methods defined with an explicit receiver' do
    src = <<-RUBY
      class Alfa
        def self.bravo(charlie)
          delta = new(charlie)
          delta.echo
          delta.echo
        end
      end
    RUBY

    expect(src).not_to reek_of(:FeatureEnvy)
  end

  it 'does not report module functions' do
    src = <<-RUBY
      module Alfa
        module_function
        def bravo(charlie)
          echo = delta(charlie)
          echo.foxtrot
          echo.foxtrot
        end
      end
    RUBY

    expect(src).not_to reek_of(:FeatureEnvy)
  end
end
