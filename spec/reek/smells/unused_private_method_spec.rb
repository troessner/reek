require_relative '../../spec_helper'
require_lib 'reek/smells/unused_private_method'
require_lib 'reek/examiner'
require_relative 'smell_detector_shared'

RSpec.describe Reek::Smells::UnusedPrivateMethod do
  let(:configuration) do
    test_configuration_for(
      described_class =>
        { Reek::Smells::SmellConfiguration::ENABLED_KEY => true }
    )
  end
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

      expect(source).to reek_of(:UnusedPrivateMethod, { name: :start }, configuration)
      expect(source).to reek_of(:UnusedPrivateMethod, { name: :drive }, configuration)
    end

    it 'creates warnings correctly' do
      source = <<-EOF
        class Car
          private
          def start; end
          def drive; end
        end
      EOF

      examiner = Reek::Examiner.new(source, 'UnusedPrivateMethod', configuration: configuration)

      first_warning = examiner.smells.first
      expect(first_warning.smell_type).to eq(Reek::Smells::UnusedPrivateMethod.smell_type)
      expect(first_warning.parameters[:name]).to eq(:drive)
      expect(first_warning.lines).to eq([4])

      second_warning = examiner.smells.last
      expect(second_warning.smell_type).to eq(Reek::Smells::UnusedPrivateMethod.smell_type)
      expect(second_warning.parameters[:name]).to eq(:start)
      expect(second_warning.lines).to eq([3])
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

      examiner = Reek::Examiner.new(source, 'UnusedPrivateMethod', configuration: configuration)

      expect(examiner.smells.size).to eq(1)
      warning_for_drive = examiner.smells.first
      expect(warning_for_drive.parameters[:name]).to eq(:drive)
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
end
