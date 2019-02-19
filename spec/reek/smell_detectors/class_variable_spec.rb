require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/class_variable'

RSpec.describe Reek::SmellDetectors::ClassVariable do
  it 'reports the right values' do
    src = <<-RUBY
      class Alfa
        @@bravo = 5
      end
    RUBY

    expect(src).to reek_of(:ClassVariable,
                           lines:   [2],
                           context: 'Alfa',
                           message: "declares the class variable '@@bravo'",
                           source:  'string',
                           name:    '@@bravo')
  end

  it 'does count all class variables' do
    src = <<-RUBY
      class Alfa
        @@bravo = 42
        @@charlie = 99
      end
    RUBY

    expect(src).
      to reek_of(:ClassVariable, name: '@@bravo').
      and reek_of(:ClassVariable, name: '@@charlie')
  end

  it 'does not report class instance variables' do
    src = <<-RUBY
      class Alfa
        @bravo = 42
      end
    RUBY

    expect(src).not_to reek_of(:ClassVariable)
  end

  context 'with no class variables' do
    it 'records nothing in the class' do
      src = <<-RUBY
        class Alfa
          def bravo; end
        end
      RUBY

      expect(src).not_to reek_of(:ClassVariable)
    end

    it 'records nothing in the module' do
      src = <<-RUBY
        module Alfa
          def bravo; end
        end
      RUBY

      expect(src).not_to reek_of(:ClassVariable)
    end
  end

  ['class', 'module'].each do |scope|
    context "when examining a #{scope}" do
      it 'reports a class variable set in a method' do
        src = <<-RUBY
          #{scope} Alfa
            def bravo
              @@charlie = {}
            end
          end
        RUBY

        expect(src).to reek_of(:ClassVariable, name: '@@charlie')
      end

      it 'reports a class variable used in a method' do
        src = <<-RUBY
          #{scope} Alfa
            def bravo
              puts @@charlie
            end
          end
        RUBY

        expect(src).to reek_of(:ClassVariable, name: '@@charlie')
      end

      it "reports a class variable set in the #{scope} body and used in a method" do
        src = <<-RUBY
          #{scope} Alfa
            @@bravo = 42

            def charlie
              puts @@bravo
            end
          end
        RUBY

        expect(src).to reek_of(:ClassVariable, name: '@@bravo')
      end
    end
  end
end
