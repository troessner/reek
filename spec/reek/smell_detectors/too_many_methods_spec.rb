# frozen_string_literal: true

require_relative '../../spec_helper'
require_lib 'reek/smell_detectors/too_many_methods'

RSpec.describe Reek::SmellDetectors::TooManyMethods do
  let(:config) do
    { described_class::MAX_ALLOWED_METHODS_KEY => 3 }
  end

  it 'reports the right values' do
    src = <<-RUBY
      class Alfa
        def bravo; end
        def charlie; end
        def delta; end
        def echo; end
      end
    RUBY

    expect(src).to reek_of(:TooManyMethods,
                           lines:   [1],
                           context: 'Alfa',
                           message: 'has at least 4 methods',
                           source:  'string',
                           count:   4).with_config(config)
  end

  it 'does not report if we stay below max_methods' do
    src = <<-RUBY
      class Alfa
        def bravo; end
        def charlie; end
        def delta; end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyMethods).with_config(config)
  end

  it 'stops at a nested module' do
    src = <<-RUBY
      class Alfa
        def bravo; end
        def charlie; end

        module Hidden
          def delta; end
          def echo; end
        end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyMethods).with_config(config)
  end

  it 'stops at a nested Struct definition' do
    src = <<-RUBY
      class Alfa
        Hidden = Struct.new(:bravo) do
          def charlie; end
          def delta; end
        end

        def echo; end
        def foxtrot; end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyMethods).with_config(config)
  end

  it 'stops at a nested Class.new definition' do
    src = <<-RUBY
      class Alfa
        Hidden = Class.new do
          def charlie; end
          def delta; end
        end

        def echo; end
        def foxtrot; end
      end
    RUBY

    expect(src).not_to reek_of(:TooManyMethods).with_config(config)
  end

  it 'counts methods defined in other kinds of constant assignment' do
    src = <<-RUBY
      class Alfa
        Bravo = class_eval do
          def charlie; end
          def delta; end
        end
        Echo = def foxtrot; end
        def golf; end
      end
    RUBY

    expect(src).to reek_of(:TooManyMethods, count: 4).with_config(config)
  end

  it 'counts an outer method that looks the same as one in a nested Struct' do
    src = <<-RUBY
      class Alfa
        Hidden = Struct.new(:bravo) do
          def charlie; end
        end

        def charlie; end
        def delta; end
        def echo; end
        def foxtrot; end
      end
    RUBY

    expect(src).to reek_of(:TooManyMethods, count: 4).with_config(config)
  end
end
