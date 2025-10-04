# frozen_string_literal: true

require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/utility_function'

RSpec.describe Reek::SmellDetectors::UtilityFunction do
  it 'reports the right values' do
    src = <<-RUBY
      def alfa(bravo)
        bravo.charlie.delta
      end
    RUBY

    expect(src).to reek_of(:UtilityFunction,
                           lines:   [1],
                           context: 'alfa',
                           message: "doesn't depend on instance state (maybe move it to another class?)",
                           source:  'string')
  end

  it 'counts a local call in a param initializer' do
    src = 'def alfa(bravo = charlie) bravo.to_s end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'counts usages of self' do
    src = 'def alfa(bravo); alfa.bravo(self); end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'counts self reference within a dstr' do
    src = 'def alfa(bravo); "#{self} #{bravo}"; end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'counts calls to self within a dstr' do
    src = 'def alfa(bravo); "#{self.gsub(/charlie/, /delta/)}"; end'
    expect(src).
      not_to reek_of(:UtilityFunction)
  end

  it 'does not report a method that calls super' do
    src = 'def alfa(bravo) super; bravo.to_s; end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'does not report a method that calls super with arguments' do
    src = 'def alfa(bravo) super(bravo); bravo.to_s; end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'recognises a deep call' do
    src = <<-RUBY
        class Alfa
          def bravo(charlie)
            charlie.each { |delta| foxtrot(delta) }
          end

          def foxtrot(golf)
            @india << golf
          end
        end
    RUBY

    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'does not report empty method' do
    src = 'def alfa(bravo); end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'does not report literal' do
    src = 'def alfa; 3; end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'does not report instance variable reference' do
    src = 'def alfa; @bravo; end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'does not report vcall' do
    src = 'def alfa; bravo; end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'does not report references to self' do
    src = 'def alfa; self; end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'recognises an ivar reference within a block' do
    src = 'def alfa(bravo) bravo.each { @charlie = 3} end'
    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'reports a call to a constant' do
    src = 'def simple(arga) FIELDS[arga] end'
    expect(src).to reek_of(:UtilityFunction, context: 'simple')
  end

  context 'when examining singleton methods' do
    ['class', 'module'].each do |scope|
      it "does not report for #{scope} with `class << self` notation" do
        src = "#{scope} Alfa; class << self; def bravo(charlie) charlie.to_s; end; end; end"
        expect(src).not_to reek_of(:UtilityFunction)
      end

      it "does not report for #{scope} with `self.` notation" do
        src = "#{scope} Alfa; def self.bravo(charlie) charlie.to_s; end; end"
        expect(src).not_to reek_of(:UtilityFunction)
      end
    end

    context 'when defined by using `module_function`' do
      it 'does not report UtilityFunction also when using multiple arguments' do
        src = <<-RUBY
          class Alfa
            def bravo(charlie) charlie.to_s; end
            def delta(echo) echo.to_s; end
            module_function :bravo, :delta
          end
        RUBY

        expect(src).not_to reek_of(:UtilityFunction)
      end

      it 'does not report module functions defined by earlier modifier' do
        src = <<-RUBY
          module Alfa
            module_function
            def bravo(charlie) charlie.to_s; end
          end
        RUBY

        expect(src).not_to reek_of(:UtilityFunction)
      end

      it 'reports functions preceded by canceled modifier' do
        src = <<-RUBY
          module Alfa
            module_function
            public
            def bravo(charlie) charlie.to_s; end
          end
        RUBY

        expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo')
      end

      it 'does not report when module_function is called in separate scope' do
        src = <<-RUBY
          class Alfa
            def bravo(charlie) charlie.to_s; end
            begin
              module_function :bravo
            end
          end
        RUBY
        expect(src).not_to reek_of(:UtilityFunction)
      end
    end
  end

  context 'when examining refinements' do
    it 'reports on the refined class' do
      src = <<-RUBY
        module Alfa
          refine Bravo do
            def bravo(charlie)
              charlie.delta.echo
            end
          end
        end
      RUBY

      expect(src).to reek_of(:UtilityFunction, context: 'Bravo#bravo')
    end
  end

  context 'when examining class_methods block' do
    it 'does not report methods defined in class_methods block' do
      src = <<-RUBY
        module Alpha
          extend ActiveSupport::Concern

          class_methods do
            def bravo(arg1, arg2)
              return 1 if arg1.something?
              return 2 if arg2.something_else?

              3
            end
          end
        end
      RUBY

      expect(src).not_to reek_of(:UtilityFunction, context: 'Alpha#bravo')
    end

    it 'reports methods defined outside the class_methods block' do
      src = <<-RUBY
        module Alpha
          extend ActiveSupport::Concern

          class_methods do
            def bravo(arg1, arg2)
              return 1 if arg1.something?
              return 2 if arg2.something_else?

              3
            end
          end

          def charlie(arg1, arg2)
            return 4 if arg1.something?
            return 5 if arg2.something_else?

            6
          end
        end
      RUBY

      expect(src).not_to reek_of(:UtilityFunction, context: 'Alpha#charlie')
    end
  end

  describe 'method visibility' do
    it 'reports private methods' do
      src = <<-RUBY
        class Alfa
          private
          def bravo(charlie)
            charlie.delta.echo
          end
        end
      RUBY

      expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo')
    end

    it 'reports protected methods' do
      src = <<-RUBY
        class Alfa
          protected
          def bravo(charlie)
            charlie.delta.echo
          end
        end
      RUBY

      expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo')
    end
  end

  describe 'disabling UtilityFunction via configuration for non-public methods' do
    let(:config) do
      { described_class::PUBLIC_METHODS_ONLY_KEY => true }
    end

    context 'when examining public methods' do
      it 'still reports UtilityFunction' do
        src = <<-RUBY
          class Alfa
            def bravo(charlie)
              charlie.delta.echo
            end
          end
        RUBY

        expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo').with_config(config)
      end
    end

    context 'when examining private methods' do
      it 'does not report UtilityFunction' do
        src = <<-RUBY
          class Alfa
            private
            def bravo(charlie)
              charlie.delta.echo
            end
          end
        RUBY

        expect(src).not_to reek_of(:UtilityFunction).with_config(config)
      end

      it 'does not report UtilityFunction when private is used as a def modifier' do
        src = <<-RUBY
          class Alfa
            private def bravo(charlie)
              charlie.delta.echo
            end
          end
        RUBY

        expect(src).not_to reek_of(:UtilityFunction).with_config(config)
      end
    end

    context 'when examining protected methods' do
      it 'does not report UtilityFunction' do
        src = <<-RUBY
          class Alfa
            protected
            def bravo(charlie)
              charlie.delta.echo
            end
          end
        RUBY

        expect(src).not_to reek_of(:UtilityFunction).with_config(config)
      end

      it 'does not report UtilityFunction when protected is used as a def modifier' do
        src = <<-RUBY
          class Alfa
            protected def bravo(charlie)
              charlie.delta.echo
            end
          end
        RUBY

        expect(src).not_to reek_of(:UtilityFunction).with_config(config)
      end
    end
  end

  describe 'disabling with a comment' do
    it 'disables the method following the comment' do
      src = <<-RUBY
        class Alfa
          # :reek:UtilityFunction
          def bravo(charlie)
            charlie.delta.echo
          end
        end
      RUBY

      expect(src).not_to reek_of(:UtilityFunction)
    end

    it 'disables a method when it has a visibility modifier' do
      src = <<-RUBY
        class Alfa
          # :reek:UtilityFunction
          private def bravo(charlie)
            charlie.delta.echo
          end
        end
      RUBY

      expect(src).not_to reek_of(:UtilityFunction)
    end
  end
end
