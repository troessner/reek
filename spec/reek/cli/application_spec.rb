require_relative '../../spec_helper'
require_lib 'reek/cli/application'

RSpec.describe Reek::CLI::Application do
  describe '#initialize' do
    it 'exits with default error code on invalid options' do
      call = lambda do
        Reek::CLI::Silencer.silently do
          described_class.new ['--foo']
        end
      end
      expect(&call).to raise_error(SystemExit) do |error|
        expect(error.status).to eq Reek::CLI::Status::DEFAULT_ERROR_EXIT_CODE
      end
    end
  end

  describe '#execute' do
    let(:path_excluded_in_configuration) do
      SAMPLES_DIR.join('source_with_exclude_paths/ignore_me/uncommunicative_method_name.rb')
    end
    let(:configuration) { test_configuration_for(CONFIGURATION_DIR.join('with_excluded_paths.reek')) }
    let(:command) { instance_double 'Reek::CLI::Command::ReportCommand' }
    let(:app) { described_class.new [] }

    before do
      allow(Reek::CLI::Command::ReportCommand).to receive(:new).and_return command
      allow(command).to receive(:execute).and_return 'foo'
    end

    it "returns the command's result code" do
      expect(app.execute).to eq 'foo'
    end

    context 'when no source files given and input was piped' do
      before do
        allow_any_instance_of(IO).to receive(:tty?).and_return(false)
      end

      it 'uses source from pipe' do
        expected_sources = a_collection_containing_exactly(have_attributes(origin: 'STDIN'))
        app.execute
        expect(Reek::CLI::Command::ReportCommand).to have_received(:new).
          with(sources: expected_sources,
               configuration: Reek::Configuration::AppConfiguration,
               options: Reek::CLI::Options)
      end

      context 'when a stdin filename is provided' do
        let(:app) { described_class.new ['--stdin-filename', 'foo.rb'] }

        it 'assumes that filename' do
          expected_sources = a_collection_containing_exactly(have_attributes(origin: 'foo.rb'))
          app.execute
          expect(Reek::CLI::Command::ReportCommand).to have_received(:new).
            with(sources: expected_sources,
                 configuration: Reek::Configuration::AppConfiguration,
                 options: Reek::CLI::Options)
        end
      end
    end

    context 'when no source files given and no input was piped' do
      before do
        allow_any_instance_of(IO).to receive(:tty?).and_return(true)
      end

      it 'uses working directory as source' do
        expected_sources = Reek::Source::SourceLocator.new(['.']).sources
        app.execute
        expect(Reek::CLI::Command::ReportCommand).to have_received(:new).
          with(sources: expected_sources,
               configuration: Reek::Configuration::AppConfiguration,
               options: Reek::CLI::Options)
      end

      context 'when source files are excluded through configuration' do
        let(:app) { described_class.new ['--config', 'some_file.reek'] }

        before do
          allow(Reek::Configuration::AppConfiguration).
            to receive(:from_path).
            with(Pathname.new('some_file.reek')).
            and_return configuration
        end

        it 'uses configuration for excluded paths' do
          expected_sources = Reek::Source::SourceLocator.
            new(['.'], configuration: configuration).sources
          expect(expected_sources).not_to include(path_excluded_in_configuration)

          app.execute

          expect(Reek::CLI::Command::ReportCommand).to have_received(:new).
            with(sources: expected_sources,
                 configuration: configuration,
                 options: Reek::CLI::Options)
        end
      end
    end

    context 'when source files given' do
      let(:app) { described_class.new ['.'] }

      it 'uses sources from argv' do
        expected_sources = Reek::Source::SourceLocator.new(['.']).sources
        app.execute
        expect(Reek::CLI::Command::ReportCommand).to have_received(:new).
          with(sources: expected_sources,
               configuration: Reek::Configuration::AppConfiguration,
               options: Reek::CLI::Options)
      end

      context 'when source files are excluded through configuration' do
        let(:app) { described_class.new ['--config', 'some_file.reek', '.'] }

        before do
          allow(Reek::Configuration::AppConfiguration).
            to receive(:from_path).
            with(Pathname.new('some_file.reek')).
            and_return configuration
        end

        it 'uses configuration for excluded paths' do
          expected_sources = Reek::Source::SourceLocator.
            new(['.'], configuration: configuration).sources
          expect(expected_sources).not_to include(path_excluded_in_configuration)

          app.execute

          expect(Reek::CLI::Command::ReportCommand).to have_received(:new).
            with(sources: expected_sources,
                 configuration: configuration,
                 options: Reek::CLI::Options)
        end
      end
    end
  end

  describe 'show configuration path' do
    let(:app) { described_class.new ['--show-configuration-path', '.'] }

    around do |example|
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          example.run
        end
      end
    end

    context 'when not using any configuration file' do
      it 'prints that we are not using any configuration file' do
        expect do
          app.execute
        end.to output("Not using any configuration file.\n").to_stdout
      end
    end

    context 'with a default configuration file' do
      it 'prints that we are using the default configuration file' do
        FileUtils.touch '.reek.yml'
        expect do
          app.execute
        end.to output("Using '.reek.yml' as configuration file.\n").to_stdout
      end
    end
  end
end
