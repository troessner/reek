require_relative '../spec_helper'
require_lib 'reek/examiner'

RSpec.shared_examples_for 'no smells found' do
  it 'is not smelly' do
    expect(examiner).not_to be_smelly
  end
  it 'finds no smells' do
    expect(examiner.smells.length).to eq(0)
  end
end

RSpec.shared_examples_for 'one smell found' do
  it 'is smelly' do
    expect(examiner).to be_smelly
  end

  it 'reports the smell' do
    expect(examiner.smells.length).to eq(1)
  end

  it 'reports the correct smell' do
    expect(examiner.smells[0].smell_type).to eq(expected_first_smell)
  end
end

RSpec.describe Reek::Examiner do
  context 'with a fragrant String' do
    let(:examiner) { described_class.new('def good() true; end') }

    it_should_behave_like 'no smells found'
  end

  context 'with a smelly String' do
    let(:examiner) { described_class.new('def fine() y = 4; end') }
    let(:expected_first_smell) { 'UncommunicativeVariableName' }

    it_should_behave_like 'one smell found'
  end

  context 'with a partially masked smelly File' do
    let(:configuration) { test_configuration_for(path) }
    let(:examiner) do
      described_class.new(SMELLY_FILE,
                          filter_by_smells: [],
                          configuration: configuration)
    end
    let(:path) { CONFIG_PATH.join('partial_mask.reek') }
    let(:expected_first_smell) { 'UncommunicativeVariableName' }

    it_should_behave_like 'one smell found'
  end

  context 'with a fragrant File' do
    let(:examiner) { described_class.new(CLEAN_FILE) }

    it_should_behave_like 'no smells found'
  end

  describe '.new' do
    context 'returns a proper Examiner' do
      let(:source) { 'class C; def f; end; end' }
      let(:examiner) do
        described_class.new(source)
      end

      it 'has been run on the given source' do
        expect(examiner.origin).to eq('string')
      end

      it 'has the right smells' do
        smells = examiner.smells
        expect(smells[0].message).to eq('has no descriptive comment')
        expect(smells[1].message).to eq("has the name 'f'")
        expect(smells[2].message).to eq("has the name 'C'")
      end

      it 'has the right smell count' do
        expect(examiner.smells_count).to eq(3)
      end
    end
  end

  describe '#smells' do
    it 'returns the detected smell warnings' do
      code     = 'def foo; bar.call_me(); bar.call_me(); end'
      examiner = described_class.new code, filter_by_smells: ['DuplicateMethodCall']

      smell = examiner.smells.first
      expect(smell).to be_a(Reek::Smells::SmellWarning)
      expect(smell.message).to eq("calls 'bar.call_me()' 2 times")
    end

    context 'source is empty' do
      let(:source) do
        <<-EOS
            # Just a comment
            # And another
        EOS
      end
      let(:examiner) do
        described_class.new(source)
      end

      it 'has no warnings' do
        expect(examiner.smells).to eq([])
      end
    end

    context 'with an incomprehensible source that causes Reek to crash' do
      let(:source) { 'class C; def does_crash_reek; end; end' }

      let(:examiner) do
        detector_repository = instance_double 'Reek::Smells::DetectorRepository'
        allow(detector_repository).to receive(:examine) do
          raise ArgumentError, 'Looks like bad source'
        end
        class_double('Reek::Smells::DetectorRepository').as_stubbed_const
        allow(Reek::Smells::DetectorRepository).to receive(:eligible_smell_types)
        allow(Reek::Smells::DetectorRepository).to receive(:new).and_return detector_repository

        described_class.new source
      end

      it 'returns no smell warnings' do
        Reek::CLI::Silencer.silently do
          expect(examiner.smells).to be_empty
        end
      end

      it 'prints the origin' do
        origin = 'string'
        expect { examiner.smells }.to output(/#{origin}/).to_stderr
      end

      it 'explains what to do' do
        explanation = 'Please double check your Reek configuration'
        expect { examiner.smells }.to output(/#{explanation}/).to_stderr
      end

      it 'contains a message' do
        original = 'Looks like bad source'
        expect { examiner.smells }.to output(/#{original}/).to_stderr
      end
    end
  end

  describe 'bad comment config' do
    context 'unknown smell detector' do
      let(:source) do
        <<-EOS
          # :reek:DoesNotExist
          def alfa; end
        EOS
      end

      it 'prints out a proper message' do
        expected_output = "You are trying to configure an unknown smell detector 'DoesNotExist'"

        expect do
          described_class.new(source).smells
        end.to output(/#{expected_output}/).to_stderr
      end

      it 'prints out a line and a source' do
        expected_output = "The source is 'string' and the comment belongs "\
                          'to the expression starting in line 2.'

        expect do
          described_class.new(source).smells
        end.to output(/#{expected_output}/).to_stderr
      end
    end

    context 'garbage in detector config' do
      let(:source) do
        <<-EOS
          # :reek:UncommunicativeMethodName { thats: a: bad: config }
          def alfa; end
        EOS
      end

      it 'prints out a proper message' do
        expected_output = "Error: You are trying to configure the smell detector 'UncommunicativeMethodName'"

        expect do
          described_class.new(source).smells
        end.to output(/#{expected_output}/).to_stderr
      end

      it 'prints out a line and a source' do
        expected_output = "The source is 'string' and "\
                          'the comment belongs to the expression starting in line 2'

        expect do
          described_class.new(source).smells
        end.to output(/#{expected_output}/).to_stderr
      end
    end
  end
end
