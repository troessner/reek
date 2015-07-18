require 'pathname'
require_relative './configuration_file_finder'

module Reek
  # @api private
  module Configuration
    # @api private
    class ConfigFileException < StandardError; end
    #
    # Reek's singleton configuration instance.
    #
    # @api private
    module AppConfiguration
      NON_SMELL_TYPE_KEYS   = %w(exclude_paths)
      EXCLUDE_PATHS_KEY     = 'exclude_paths'
      @configuration        = {}
      @has_been_initialized = false

      class << self
        attr_reader :configuration

        def initialize_with(options)
          @has_been_initialized = true
          configuration_file_path = ConfigurationFileFinder.find(options: options)
          return unless configuration_file_path
          load_from_file configuration_file_path
        end

        def configure_smell_repository(smell_repository)
          # Let users call this method directly without having initialized AppConfiguration before
          # and if they do, initialize it without application context
          initialize_with(nil) unless @has_been_initialized
          for_smell_types.each do |klass_name, config|
            klass = load_smell_type(klass_name)
            smell_repository.configure(klass, config) if klass
          end
        end

        def load_from_file(path)
          if path.size.zero?
            report_problem('Empty file', path)
            return
          end

          begin
            @configuration = YAML.load_file(path) || {}
          rescue => error
            raise_error(error.to_s, path)
          end

          raise_error('Not a hash', path) unless @configuration.is_a? Hash
        end

        def reset
          @configuration.clear
          @exclude_paths = nil
        end

        def exclude_paths
          @exclude_paths ||= begin
            @configuration.fetch(EXCLUDE_PATHS_KEY, []).map do |string|
              Pathname.new(string.chomp('/'))
            end
          end
        end

        private

        def for_smell_types
          @configuration.reject { |key, _value| NON_SMELL_TYPE_KEYS.include?(key) }
        end

        def load_smell_type(name)
          Reek::Smells.const_get(name)
        rescue NameError
          report_problem("\"#{name}\" is not a code smell")
          nil
        end

        def report_problem(reason, path)
          $stderr.puts "Warning: #{message(reason, path)}"
        end

        def raise_error(reason, path)
          raise ConfigFileException, message(reason, path)
        end

        def message(reason, path)
          "Invalid configuration file \"#{File.basename(path)}\" -- #{reason}"
        end
      end
    end
  end
end
