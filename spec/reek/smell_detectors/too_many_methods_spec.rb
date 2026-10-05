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

  describe 'visibility specific thresholds' do
    let(:source) do
      <<-RUBY
        class Alfa
          def bravo; end
          def charlie; end

          protected

          def delta; end

          private

          def echo; end
          def foxtrot; end
          def golf; end
        end
      RUBY
    end

    it 'does not check any visibility by default' do
      expect(source).not_to reek_of(:TooManyMethods)
    end

    it 'reports the right values for max_public_methods' do
      config = { described_class::MAX_PUBLIC_METHODS_KEY => 1 }

      expect(source).to reek_of(:TooManyMethods,
                                lines:   [1],
                                context: 'Alfa',
                                message: 'has at least 2 public methods',
                                source:  'string',
                                count:   2).with_config(config)
    end

    it 'does not report if we stay below max_public_methods' do
      config = { described_class::MAX_PUBLIC_METHODS_KEY => 2 }

      expect(source).not_to reek_of(:TooManyMethods).with_config(config)
    end

    it 'reports the right values for max_protected_methods' do
      config = { described_class::MAX_PROTECTED_METHODS_KEY => 0 }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 1 protected methods',
                                count:   1).with_config(config)
    end

    it 'reports the right values for max_private_methods' do
      config = { described_class::MAX_PRIVATE_METHODS_KEY => 2 }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 3 private methods',
                                count:   3).with_config(config)
    end

    it 'does not report if we stay below max_private_methods' do
      config = { described_class::MAX_PRIVATE_METHODS_KEY => 3 }

      expect(source).not_to reek_of(:TooManyMethods).with_config(config)
    end

    it 'reports the right values for max_private_and_protected_methods' do
      config = { described_class::MAX_PRIVATE_AND_PROTECTED_METHODS_KEY => 3 }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 4 private and protected methods',
                                count:   4).with_config(config)
    end

    it 'does not report if we stay below max_private_and_protected_methods' do
      config = { described_class::MAX_PRIVATE_AND_PROTECTED_METHODS_KEY => 4 }

      expect(source).not_to reek_of(:TooManyMethods).with_config(config)
    end

    it 'reports the general and the visibility specific threshold independently' do
      config = {
        described_class::MAX_ALLOWED_METHODS_KEY => 5,
        described_class::MAX_PUBLIC_METHODS_KEY  => 1
      }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 6 methods').with_config(config)
      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 2 public methods').with_config(config)
    end

    it 'counts methods defined in a singleton class towards their visibility' do
      src = <<-RUBY
        class Alfa
          class << self
            def bravo; end

            private

            def charlie; end
            def delta; end
          end
        end
      RUBY
      config = { described_class::MAX_PRIVATE_METHODS_KEY => 1 }

      expect(src).to reek_of(:TooManyMethods,
                             message: 'has at least 2 private methods',
                             count:   2).with_config(config)
    end
  end

  describe 'ignoring methods by visibility' do
    let(:source) do
      <<-RUBY
        class Alfa
          def bravo; end
          def charlie; end

          protected

          def delta; end

          private

          def echo; end
          def foxtrot; end
        end
      RUBY
    end

    it 'counts every method by default' do
      config = { described_class::MAX_ALLOWED_METHODS_KEY => 4 }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 5 methods',
                                count:   5).with_config(config)
    end

    it 'excludes private methods from the general count when ignore_private_methods is set' do
      config = {
        described_class::MAX_ALLOWED_METHODS_KEY    => 2,
        described_class::IGNORE_PRIVATE_METHODS_KEY => true
      }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 3 methods',
                                count:   3).with_config(config)
    end

    it 'excludes protected methods from the general count when ignore_protected_methods is set' do
      config = {
        described_class::MAX_ALLOWED_METHODS_KEY      => 3,
        described_class::IGNORE_PROTECTED_METHODS_KEY => true
      }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 4 methods',
                                count:   4).with_config(config)
    end

    it 'excludes public methods from the general count when ignore_public_methods is set' do
      config = {
        described_class::MAX_ALLOWED_METHODS_KEY   => 2,
        described_class::IGNORE_PUBLIC_METHODS_KEY => true
      }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 3 methods',
                                count:   3).with_config(config)
    end

    it 'checks public methods only when both other visibilities are ignored' do
      config = {
        described_class::MAX_ALLOWED_METHODS_KEY      => 1,
        described_class::IGNORE_PRIVATE_METHODS_KEY   => true,
        described_class::IGNORE_PROTECTED_METHODS_KEY => true
      }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 2 methods',
                                count:   2).with_config(config)
    end

    it 'does not report when everything above the threshold is ignored' do
      config = {
        described_class::MAX_ALLOWED_METHODS_KEY      => 2,
        described_class::IGNORE_PRIVATE_METHODS_KEY   => true,
        described_class::IGNORE_PROTECTED_METHODS_KEY => true
      }

      expect(source).not_to reek_of(:TooManyMethods).with_config(config)
    end

    it 'skips the visibility specific threshold for an ignored visibility' do
      config = {
        described_class::MAX_PRIVATE_METHODS_KEY    => 1,
        described_class::IGNORE_PRIVATE_METHODS_KEY => true
      }

      expect(source).not_to reek_of(:TooManyMethods).with_config(config)
    end

    it 'drops an ignored visibility from a combined threshold' do
      config = {
        described_class::MAX_PRIVATE_AND_PROTECTED_METHODS_KEY => 1,
        described_class::IGNORE_PROTECTED_METHODS_KEY          => true
      }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 2 private methods',
                                count:   2).with_config(config)
    end

    it 'leaves only the other visibility in a combined threshold' do
      config = {
        described_class::MAX_PRIVATE_AND_PROTECTED_METHODS_KEY => 0,
        described_class::IGNORE_PRIVATE_METHODS_KEY            => true
      }

      expect(source).to reek_of(:TooManyMethods,
                                message: 'has at least 1 protected methods',
                                count:   1).with_config(config)
    end
  end
end
