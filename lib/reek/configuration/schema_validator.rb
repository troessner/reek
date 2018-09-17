# frozen_string_literal: true

require 'yaml'
require_relative '../cli/silencer'
Reek::CLI::Silencer.without_warnings { require 'kwalify' }
require_relative '../errors/config_file_error'

module Reek
  module Configuration
    #
    # Schema validator module.
    #
    class SchemaValidator
      SCHEMA_FILE_PATH = File.expand_path('./schema.yml', __dir__)

      def initialize(configuration)
        @configuration = configuration
        @validator = CLI::Silencer.without_warnings do
          schema_file = Kwalify::Yaml.load_file(SCHEMA_FILE_PATH)
          Kwalify::Validator.new(schema_file)
        end
      end

      def validate
        errors = CLI::Silencer.without_warnings { @validator.validate @configuration }
        return if !errors || errors.empty?

        raise Errors::ConfigFileError, error_message(errors)
      end

      private

      # :reek:UtilityFunction
      def error_message(errors)
        "We found some problems with your configuration file: #{CLI::Silencer.silently { errors.join(', ') }}"
      end
    end
  end
end
