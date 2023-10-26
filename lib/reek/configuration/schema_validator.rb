# frozen_string_literal: true

require_relative '../errors/config_file_error'
require_relative 'schema'

module Reek
  module Configuration
    #
    # Schema validator module.
    #
    class SchemaValidator
      def initialize(configuration)
        @configuration = configuration
        config_directories = configuration['directories']&.keys || []
        @validator = Reek::Configuration::Schema.schema(config_directories)
      end

      def validate
        result = @validator.call(@configuration)
        return if result.success?

        raise Errors::ConfigFileError, error_message(result.errors)
      rescue NoMethodError
        raise Errors::ConfigFileError, 'unrecognized configuration data'
      end

      private

      # :reek:UtilityFunction
      def error_message(errors)
        messages = errors.map do |error|
          "[/#{error.path.join('/')}] #{error.text}."
        end.join("\n")
        "\n#{messages}"
      end
    end
  end
end
