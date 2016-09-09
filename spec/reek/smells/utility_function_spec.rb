require_relative '../../spec_helper'
require_lib 'reek/smells/utility_function'

RSpec.describe Reek::Smells::UtilityFunction do
  it 'reports the right values' do
    src = <<-EOS
      def alfa(bravo)
        bravo.charlie.delta
      end
    EOS

    expect(src).to reek_of(:UtilityFunction,
                           lines:   [1],
                           context: 'alfa',
                           message: "doesn't depend on instance state (maybe move it to another class?)",
                           source:  'string')
  end

  it 'counts a local call in a param initializer' do
    expect('def alfa(bravo = charlie) bravo.to_s end').not_to reek_of(:UtilityFunction)
  end

  it 'counts usages of self' do
    expect('def alfa(bravo); alfa.bravo(self); end').not_to reek_of(:UtilityFunction)
  end

  it 'counts self reference within a dstr' do
    expect('def alfa(bravo); "#{self} #{bravo}"; end').not_to reek_of(:UtilityFunction)
  end

  it 'counts calls to self within a dstr' do
    expect('def alfa(bravo); "#{self.gsub(/charlie/, /delta/)}"; end').
      not_to reek_of(:UtilityFunction)
  end

  it 'does not report a method that calls super' do
    expect('def alfa(bravo) super; bravo.to_s; end').not_to reek_of(:UtilityFunction)
  end

  it 'does not report a method that calls super with arguments' do
    expect('def alfa(bravo) super(bravo); bravo.to_s; end').not_to reek_of(:UtilityFunction)
  end

  it 'should recognise a deep call' do
    src = <<-EOS
        class Alfa
          def bravo(charlie)
            charlie.each { |delta| foxtrot(delta) }
          end

          def foxtrot(golf)
            @india << golf
          end
        end
    EOS

    expect(src).not_to reek_of(:UtilityFunction)
  end

  it 'does not report empty method' do
    expect('def alfa(bravo); end').not_to reek_of(:UtilityFunction)
  end

  it 'does not report literal' do
    expect('def alfa; 3; end').not_to reek_of(:UtilityFunction)
  end

  it 'does not report instance variable reference' do
    expect('def alfa; @bravo; end').not_to reek_of(:UtilityFunction)
  end

  it 'does not report vcall' do
    expect('def alfa; bravo; end').not_to reek_of(:UtilityFunction)
  end

  it 'does not report references to self' do
    expect('def alfa; self; end').not_to reek_of(:UtilityFunction)
  end

  it 'recognises an ivar reference within a block' do
    expect('def alfa(bravo) bravo.each { @charlie = 3} end').not_to reek_of(:UtilityFunction)
  end

  it 'reports a call to a constant' do
    expect('def simple(arga) FIELDS[arga] end').to reek_of(:UtilityFunction, context: 'simple')
  end

  context 'Singleton methods' do
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

    context 'by using `module_function`' do
      it 'does not report UtilityFunction also when using multiple arguments' do
        src = <<-EOS
          class Alfa
            def bravo(charlie) charlie.to_s; end
            def delta(echo) echo.to_s; end
            module_function :bravo, :delta
          end
        EOS

        expect(src).not_to reek_of(:UtilityFunction)
      end

      it 'does not report module functions defined by earlier modifier' do
        src = <<-EOF
          module Alfa
            module_function
            def bravo(charlie) charlie.to_s; end
          end
        EOF

        expect(src).not_to reek_of(:UtilityFunction)
      end

      it 'reports functions preceded by canceled modifier' do
        src = <<-EOF
          module Alfa
            module_function
            public
            def bravo(charlie) charlie.to_s; end
          end
        EOF

        expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo')
      end

      it 'does not report when module_function is called in separate scope' do
        src = <<-EOF
          class Alfa
            def bravo(charlie) charlie.to_s; end
            begin
              module_function :bravo
            end
          end
        EOF
        expect(src).not_to reek_of(:UtilityFunction)
      end
    end
  end

  describe 'method visibility' do
    it 'reports private methods' do
      src = <<-EOS
        class Alfa
          private
          def bravo(charlie)
            charlie.delta.echo
          end
        end
      EOS

      expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo')
    end

    it 'reports protected methods' do
      src = <<-EOS
        class Alfa
          protected
          def bravo(charlie)
            charlie.delta.echo
          end
        end
      EOS

      expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo')
    end
  end

  describe 'disabling UtilityFunction via configuration for non-public methods' do
    let(:config) do
      { Reek::Smells::UtilityFunction::PUBLIC_METHODS_ONLY_KEY => true }
    end

    context 'public methods' do
      it 'still reports UtilityFunction' do
        src = <<-EOS
          class Alfa
            def bravo(charlie)
              charlie.delta.echo
            end
          end
        EOS

        expect(src).to reek_of(:UtilityFunction, context: 'Alfa#bravo').with_config(config)
      end
    end

    context 'private methods' do
      it 'does not report UtilityFunction' do
        src = <<-EOS
          class Alfa
            private
            def bravo(charlie)
              charlie.delta.echo
            end
          end
        EOS

        expect(src).not_to reek_of(:UtilityFunction).with_config(config)
      end
    end

    context 'protected methods' do
      it 'does not report UtilityFunction' do
        src = <<-EOS
          class Alfa
            protected
            def bravo(charlie)
              charlie.delta.echo
            end
          end
        EOS

        expect(src).not_to reek_of(:UtilityFunction).with_config(config)
      end
    end
  end
end
