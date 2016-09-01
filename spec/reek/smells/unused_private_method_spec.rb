require_relative '../../spec_helper'
require_lib 'reek/smells/unused_private_method'

RSpec.describe Reek::Smells::UnusedPrivateMethod do
  it 'reports the right values' do
    src = <<-EOS
      class Dummy
        private

        def m
        end
      end
    EOS

    expect(src).to reek_of(:UnusedPrivateMethod,
                           lines:   [4],
                           context: 'Dummy',
                           message: 'has the unused private instance method `m`',
                           source:  'string',
                           name:    :m)
  end

  it 'does count all occurences' do
    src = <<-EOS
      class Dummy
        private

        def m1
        end

        def m2
        end
      end
    EOS

    expect(src).to reek_of(:UnusedPrivateMethod,
                           lines: [4],
                           name:  :m1)
    expect(src).to reek_of(:UnusedPrivateMethod,
                           lines: [7],
                           name:  :m2)
  end

  context 'unused private methods' do
    it 'reports instance methods' do
      source = <<-EOF
        class Car
          private
          def start; end
          def drive; end
        end
      EOF

      expect(source).to reek_of(:UnusedPrivateMethod, name: :start)
      expect(source).to reek_of(:UnusedPrivateMethod, name: :drive)
    end

    it 'reports instance methods in the correct class' do
      source = <<-EOF
        class Car
          class Engine
            private
            def start; end
          end
        end
      EOF

      expect(source).to reek_of(:UnusedPrivateMethod, context: 'Car::Engine', name: :start)
      expect(source).not_to reek_of(:UnusedPrivateMethod, context: 'Car', name: :start)
    end

    it 'discounts calls to identically named methods in nested classes' do
      source = <<-EOF
        class Car
          class Engine
            def vroom
              start
            end
            private
            def start; end
          end
          private
          def start; end
        end
      EOF

      expect(source).not_to reek_of(:UnusedPrivateMethod, context: 'Car::Engine', name: :start)
      expect(source).to reek_of(:UnusedPrivateMethod, context: 'Car', name: :start)
    end

    it 'creates warnings correctly' do
      source = <<-EOF
        class Car
          private
          def start; end
          def drive; end
        end
      EOF

      expect(source).to reek_of(:UnusedPrivateMethod, name: :drive, lines: [4])
      expect(source).to reek_of(:UnusedPrivateMethod, name: :start, lines: [3])
    end
  end

  describe 'configuring the detector via source code comment' do
    it 'does not report methods we excluded' do
      source = <<-EOF
        # :reek:UnusedPrivateMethod: { exclude: [ start ] }
        class Car
          private
          def start; end
          def drive; end
        end
      EOF

      expect(source).to reek_of(:UnusedPrivateMethod, name: :drive)
      expect(source).not_to reek_of(:UnusedPrivateMethod, name: :start)
    end
  end

  context 'used private methods' do
    it 'are not reported' do
      source = <<-EOF
        class Car
          def drive
            start
          end

          private
          def start; end
        end
      EOF

      expect(source).not_to reek_of(:UnusedPrivateMethod)
    end
  end

  context 'unused protected methods' do
    it 'are not reported' do
      source = <<-EOF
        class Car
          protected
          def start; end
        end
      EOF

      expect(source).not_to reek_of(:UnusedPrivateMethod)
    end
  end

  context 'unused public methods' do
    it 'are not reported' do
      source = <<-EOF
        class Car
          def start; end
        end
      EOF

      expect(source).not_to reek_of(:UnusedPrivateMethod)
    end
  end

  describe 'prevent methods from being reported' do
    let(:source) do
      <<-EOF
        class Car
          private
          def start; end
          def drive; end
        end
      EOF
    end

    it 'excludes them via direct match in the app configuration' do
      config = { Reek::Smells::SmellDetector::EXCLUDE_KEY => ['Car#drive'] }

      expect(source).to reek_of(:UnusedPrivateMethod, name: :start).with_config(config)
      expect(source).not_to reek_of(:UnusedPrivateMethod, name: :drive).with_config(config)
    end

    it 'excludes them via regex in the app configuration' do
      config = { Reek::Smells::SmellDetector::EXCLUDE_KEY => [/drive/] }

      expect(source).to reek_of(:UnusedPrivateMethod, name: :start).with_config(config)
      expect(source).not_to reek_of(:UnusedPrivateMethod, name: :drive).with_config(config)
    end
  end
end
