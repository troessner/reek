require_relative '../../spec_helper'
require_lib 'reek/smells/unused_private_method'
require_lib 'reek/examiner'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::UnusedPrivateMethod do
  let(:detector) { build(:smell_detector, smell_type: :UnusedPrivateMethod) }

  it_should_behave_like 'SmellDetector'

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
