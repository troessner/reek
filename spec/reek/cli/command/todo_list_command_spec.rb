# frozen_string_literal: true

require_relative '../../../spec_helper'
require_lib 'reek/cli/command/todo_list_command'
require_lib 'reek/cli/options'
require_lib 'reek/configuration/app_configuration'

RSpec.describe Reek::CLI::Command::TodoListCommand do
  let(:existing_configuration) do
    <<~YAML
      ---
      detectors:
        UncommunicativeMethodName:
          exclude:
          - Smelly#x
    YAML
  end

  let(:smelly_file) do
    <<~RUBY
      # Smelly class
      class Smelly
        # This will reek of UncommunicativeMethodName
        def x
          y = 10 # This will reek of UncommunicativeVariableName
        end
      end
    RUBY
  end

  let(:new_configuration_file) do
    <<~YAML
      # Auto generated by Reeks --todo flag
      ---
      detectors:
        UncommunicativeMethodName:
          exclude:
          - Smelly#x
        UncommunicativeVariableName:
          exclude:
          - Smelly#x
    YAML
  end

  describe '#execute on smelly source' do
    around do |example|
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          File.write SMELLY_FILE.basename, smelly_file
          example.run
        end
      end
    end

    context 'with default configuration file' do
      let(:default_configuration_file_name) { Reek::DEFAULT_CONFIGURATION_FILE_NAME }

      context 'when does not exist yet' do
        it 'creates it' do
          Reek::CLI::Silencer.silently { todo_command.execute }

          actual_content = File.read(default_configuration_file_name)
          expect(actual_content).to match(new_configuration_file)
        end
      end

      context 'when exists already' do
        it 'does not update the configuration' do
          File.write default_configuration_file_name, existing_configuration
          command = todo_command

          Reek::CLI::Silencer.silently { command.execute }

          actual_content = File.read(default_configuration_file_name)
          expect(actual_content).to match(existing_configuration)
        end
      end
    end

    def todo_command(options: Reek::CLI::Options.new([]),
                     sources: [Pathname.new(SMELLY_FILE.basename.to_s)],
                     configuration: Reek::Configuration::AppConfiguration.default)
      described_class.new options: options,
                          sources: sources,
                          configuration: configuration
    end
  end
end
