# frozen_string_literal: true

require 'yaml'
require_relative '../errors/config_file_exception'
require_relative '../../ext/Rx'

module Reek
  module Configuration
    #
    # Schema validator module.
    #
    class SchemaValidator
      SCHEMA_FILE = YAML.load_file(File.expand_path('../../../conf/schema.yml', __dir__))

      def initialize(configuration)
        @configuration = configuration
        @rx = Rx.new({ :load_core => true })
        @schema = @rx.make_schema(SCHEMA_FILE)
      end

      def self.validate(configuration)
        new(configuration).validate
      end

      def validate
        begin
          @schema.check!(@configuration)
        rescue Exception => e
          raise Errors::ConfigFileException, "Invalid configuration file: #{e.message}"
        end
      end
    end
  end
end
