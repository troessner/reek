# frozen_string_literal: true

require 'yaml'
require_relative '../errors/config_file_error'
require_relative '../cli/silencer'
require_relative '../../../ext/Rx'

module Reek
  module Configuration
    #
    # Schema validator module.
    #
    class SchemaValidator
      SCHEMA_FILE = YAML.load_file(File.expand_path('../../../conf/schema.yml', __dir__))

      def initialize(configuration)
        @configuration = configuration
        @rx = Rx.new load_core: true
        Reek::CLI::Silencer.silently do
          @schema = @rx.make_schema(SCHEMA_FILE)
        end
      end

      def self.validate(configuration)
        new(configuration).validate
      end

      def validate
        Reek::CLI::Silencer.silently do
          @schema.check!(@configuration)
        end
      rescue StandardError => error
        raise Errors::ConfigFileError, "Invalid configuration file: #{error.message}"
      end
    end
  end
end
