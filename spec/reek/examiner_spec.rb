require_relative '../spec_helper'
require_lib 'reek/examiner'
require_lib 'reek/logging_error_handler'

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

    it_behaves_like 'no smells found'
  end

  context 'with a smelly String' do
    let(:examiner) { described_class.new('def fine() y = 4; end') }
    let(:expected_first_smell) { 'UncommunicativeVariableName' }

    it_behaves_like 'one smell found'
  end

  context 'with a partially masked smelly File' do
    let(:configuration) { test_configuration_for(path) }
    let(:examiner) do
      described_class.new(SMELLY_FILE,
                          filter_by_smells: [],
                          configuration: configuration)
    end
    let(:path) { CONFIGURATION_DIR.join('partial_mask.reek') }
    let(:expected_first_smell) { 'UncommunicativeVariableName' }

    it_behaves_like 'one smell found'
  end

  context 'with a fragrant File' do
    let(:examiner) { described_class.new(CLEAN_FILE) }

    it_behaves_like 'no smells found'
  end

  describe '#origin' do
    let(:source) { 'class C; def f; end; end' }
    let(:examiner) { described_class.new(source) }

    it 'returns "string" for a string source' do
      expect(examiner.origin).to eq('string')
    end
  end

  describe '#smells' do
    it 'returns the detected smell warnings' do
      code     = 'def foo; bar.call_me(); bar.call_me(); end'
      examiner = described_class.new code, filter_by_smells: ['DuplicateMethodCall']

      smell = examiner.smells.first
      expect(smell).to be_a(Reek::SmellWarning)
      expect(smell.message).to eq("calls 'bar.call_me()' 2 times")
    end

    context 'with a source with three smells' do
      let(:source) { 'class C; def f; end; end' }
      let(:examiner) { described_class.new(source) }

      it 'has the right smells' do
        smells = examiner.smells
        expect(smells.map(&:message)).
          to eq ['has no descriptive comment',
                 "has the name 'f'",
                 "has the name 'C'"]
      end
    end

    context 'when source only contains comments' do
      let(:source) do
        <<-RUBY
            # Just a comment
            # And another
        RUBY
      end
      let(:examiner) do
        described_class.new(source)
      end

      it 'has no warnings' do
        expect(examiner.smells).to eq([])
      end
    end

    context 'with an incomprehensible source that causes the detectors to crash' do
      let(:source) { 'class C; def does_crash_reek; end; end' }

      let(:examiner) do
        detector_repository = instance_double 'Reek::DetectorRepository'
        allow(detector_repository).to receive(:examine) do
          raise ArgumentError, 'Looks like bad source'
        end
        class_double('Reek::DetectorRepository').as_stubbed_const
        allow(Reek::DetectorRepository).to receive(:eligible_smell_types)
        allow(Reek::DetectorRepository).to receive(:new).and_return detector_repository

        described_class.new source
      end

      it 'raises an incomprehensible source error' do
        expect { examiner.smells }.to raise_error Reek::Errors::IncomprehensibleSourceError
      end

      it 'explains the origin of the error' do
        origin = 'string'
        expect { examiner.smells }.
          to raise_error.with_message("Source #{origin} cannot be processed by Reek.")
      end

      it 'explains what to do' do
        explanation = 'It would be great if you could report this back to the Reek team'
        expect { examiner.smells }.
          to raise_error { |it| expect(it.long_message).to match(/#{explanation}/) }
      end

      it 'contains the original error message' do
        original = 'Looks like bad source'
        expect { examiner.smells }.
          to raise_error { |it| expect(it.long_message).to match(/#{original}/) }
      end

      it 'shows the original exception class' do
        expect { examiner.smells }.
          to raise_error { |it| expect(it.long_message).to match(/ArgumentError/) }
      end
    end
  end

  describe '#smells_count' do
    let(:source) { 'class C; def f; end; end' }
    let(:examiner) { described_class.new(source) }

    it 'has the right smell count' do
      expect(examiner.smells_count).to eq(3)
    end
  end

  context 'when the source causes the source buffer to crash' do
    let(:source) { 'I make the buffer crash' }

    before do
      buffer = double
      allow(buffer).to receive(:source=) { raise RuntimeError }
      allow(Parser::Source::Buffer).to receive(:new).and_return(buffer)
    end

    context 'when the error handler does not handle the error' do
      let(:examiner) { described_class.new(source) }

      it 'does not raise an error during initialization' do
        expect { examiner }.not_to raise_error
      end

      it 'raises an incomprehensible source error when asked for smells' do
        expect { examiner.smells }.to raise_error Reek::Errors::IncomprehensibleSourceError
      end
    end

    context 'when the error handler handles the error' do
      let(:handler) { instance_double(Reek::LoggingErrorHandler, handle: true) }
      let(:examiner) { described_class.new(source, error_handler: handler) }

      it 'does not raise an error when asked for smells' do
        expect { examiner.smells }.not_to raise_error
      end

      it 'passes the wrapped error to the handler' do
        examiner.smells
        expect(handler).to have_received(:handle).with(Reek::Errors::IncomprehensibleSourceError)
      end
    end
  end

  context 'with a source that triggers a syntax error' do
    let(:examiner) { described_class.new(source) }
    let(:source) do
      <<~RUBY
        1 2 3
      RUBY
    end

    it 'does not raise an error during initialization' do
      expect { examiner }.not_to raise_error
    end

    it 'raises an encoding error when asked for smells' do
      expect { examiner.smells }.to raise_error Reek::Errors::SyntaxError
    end

    it 'explains the origin of the error' do
      message = "Source 'string' cannot be processed by Reek due to a syntax error in the source file."
      expect { examiner.smells }.to raise_error.with_message(/#{message}/)
    end

    it 'shows the original exception class' do
      expect { examiner.smells }.
        to raise_error { |it| expect(it.long_message).to match(/Parser::SyntaxError/) }
    end
  end

  context 'with a source that triggers an encoding error' do
    let(:examiner) { described_class.new(source) }
    let(:source) do
      <<~RUBY
        # encoding: US-ASCII
        puts 'こんにちは世界'
      RUBY
    end

    it 'does not raise an error during initialization' do
      expect { examiner }.not_to raise_error
    end

    it 'raises an encoding error when asked for smells' do
      expect { examiner.smells }.to raise_error Reek::Errors::EncodingError
    end

    it 'explains the origin of the error' do
      message = "Source 'string' cannot be processed by Reek due to an encoding error in the source file."
      expect { examiner.smells }.to raise_error.with_message(/#{message}/)
    end

    it 'shows the original exception class' do
      expect { examiner.smells }.
        to raise_error { |it| expect(it.long_message).to match(/InvalidByteSequenceError/) }
    end
  end

  describe 'bad comment config' do
    let(:examiner) { described_class.new(source) }

    context 'with an unknown smell detector' do
      let(:source) do
        <<-RUBY
          # :reek:DoesNotExist
          def alfa; end
        RUBY
      end

      it 'raises a bad detector name error' do
        expect { examiner.smells }.to raise_error Reek::Errors::BadDetectorInCommentError
      end

      it 'explains the reason for the error' do
        message = "You are trying to configure an unknown smell detector 'DoesNotExist'"

        expect { examiner.smells }.to raise_error.with_message(/#{message}/)
      end

      it 'explains the origin of the error' do
        details = "The source is 'string' and the comment belongs "\
                  'to the expression starting in line 2.'

        expect { examiner.smells }.to raise_error.with_message(/#{details}/)
      end
    end

    context 'with garbage in detector config' do
      let(:source) do
        <<-RUBY
          # :reek:UncommunicativeMethodName { thats: a: bad: config }
          def alfa; end
        RUBY
      end

      it 'raises a garbarge configuration error' do
        expect { examiner.smells }.to raise_error Reek::Errors::GarbageDetectorConfigurationInCommentError
      end

      it 'explains the reason for the error' do
        message = "Error: You are trying to configure the smell detector 'UncommunicativeMethodName'"

        expect { examiner.smells }.to raise_error.with_message(/#{message}/)
      end

      it 'explains the origin of the error' do
        details = "The source is 'string' and the comment belongs "\
                  'to the expression starting in line 2.'

        expect { examiner.smells }.to raise_error.with_message(/#{details}/)
      end
    end
  end
end
