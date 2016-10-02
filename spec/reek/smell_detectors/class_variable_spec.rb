require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/class_variable'

RSpec.describe Reek::SmellDetectors::ClassVariable do
  it 'reports the right values' do
    src = <<-EOS
      class Alfa
        @@bravo = 5
      end
    EOS

    expect(src).to reek_of(:ClassVariable,
                           lines:   [2],
                           context: 'Alfa',
                           message: "declares the class variable '@@bravo'",
                           source:  'string',
                           name:    '@@bravo')
  end

  it 'does count all class variables' do
    src = <<-EOS
      class Alfa
        @@bravo = 42
        @@charlie = 99
      end
    EOS

    expect(src).
      to reek_of(:ClassVariable, name: '@@bravo').
      and reek_of(:ClassVariable, name: '@@charlie')
  end

  it 'does not report class instance variables' do
    src = <<-EOS
      class Alfa
        @bravo = 42
      end
    EOS

    expect(src).not_to reek_of(:ClassVariable)
  end

  context 'with no class variables' do
    it 'records nothing in the class' do
      src = <<-EOS
        class Alfa
          def bravo; end
        end
      EOS

      expect(src).not_to reek_of(:ClassVariable)
    end

    it 'records nothing in the module' do
      src = <<-EOS
        module Alfa
          def bravo; end
        end
      EOS

      expect(src).not_to reek_of(:ClassVariable)
    end
  end

  ['class', 'module'].each do |scope|
    context "Scoped to #{scope}" do
      context 'set in a method' do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} Alfa
              def bravo
                @@charlie = {}
              end
            end
          EOS

          expect(src).to reek_of(:ClassVariable)
        end
      end

      context 'used in a method' do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} Alfa
              def bravo
                puts @@charlie
              end
            end
          EOS

          expect(src).to reek_of(:ClassVariable)
        end
      end

      context "set in #{scope} and used in a method" do
        it 'reports correctly' do
          src = <<-EOS
            #{scope} Alfa
              @@bravo = 42

              def charlie
                puts @@bravo
              end
            end
          EOS

          expect(src).to reek_of(:ClassVariable)
        end
      end
    end
  end
end
