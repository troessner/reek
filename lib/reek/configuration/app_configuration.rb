require 'pathname'
require_relative './configuration_file_finder'

module Reek
  # @api private
  module Configuration
    # @api private
    #
    # Reek's singleton configuration instance.
    #
    # @api private
    class AppConfiguration
      EXCLUDE_PATHS_KEY = 'exclude_paths'
      attr_reader :exclude_paths, :default_directive, :directory_directives

      # Given this configuration file:
      #
      # ---
      # IrresponsibleModule:
      #   enabled: false
      # "app/helpers":
      #   UtilityFunction:
      #     enabled: false
      # exclude_paths:
      #   - "app/controllers"
      #
      # this would result in the following configuration:
      #
      # exclude_paths = [ Pathname('spec/samples/two_smelly_files') ]
      # default_directive = { Reek::Smells::IrresponsibleModule => { "enabled" => false } }
      # directory_directives = { Pathname("spec/samples/three_clean_files/") =>
      #                          { Reek::Smells::UtilityFunction => { "enabled" => false } } }
      #
      #
      # @param options [OpenStruct]
      #   e.g.: #<OpenStruct report_format =: text,
      #                      location_format =: numbers,
      #                      colored = true,
      #                      smells_to_detect = [],
      #                      config_file = #<Pathname:config/defaults.reek>,
      #                      argv = [ "lib/reek/spec" ]>
      def initialize(options = nil)
        @directory_directives = {}
        @default_directive    = {}
        @exclude_paths        = []

        load options
      end

      # @param source_via [String] - the source of the code inspected
      # @return [Hash] the directory directive for the source or, if there is
      # none, the default directive
      def directive_for(source_via)
        directory_directive_for_source(source_via) || default_directive
      end

      private

      private_attr_writer :exclude_paths

      # @param source_via [String] - the source of the code inspected
      # Might be a string, STDIN or Filename / Pathname. We're only interested in the source
      # when it's coming from file since a directory_directive doesn't make sense
      # for anything else.
      # @return [Hash | nil] the configuration for the source or nil
      def directory_directive_for_source(source_via)
        return unless source_via
        source_base_dir = Pathname.new(source_via).dirname
        hit = best_directory_match_for source_base_dir
        directory_directives[hit]
      end

      def load(options)
        configuration_file = ConfigurationFileFinder.find_and_load(options: options)

        configuration_file.each do |key, value|
          case
          when key == EXCLUDE_PATHS_KEY
            handle_exclude_paths(value)
          when smell_type?(key)
            handle_default_directive(key, value)
          else
            handle_directory_directive(key, value)
          end
        end
      end

      def handle_exclude_paths(paths)
        self.exclude_paths = paths.map do |path|
          pathname = Pathname.new path.chomp('/')
          raise ArgumentError, "Excluded directory #{path} does not exists" unless pathname.exist?
          pathname
        end
      end

      def handle_default_directive(key, config)
        klass = Reek::Smells.const_get(key)
        default_directive[klass] = config
      end

      def handle_directory_directive(path, config)
        pathname = Pathname.new path.chomp('/')
        validate_directive pathname

        directory_directives[pathname] = config.each_with_object({}) do |(key, value), hash|
          abort(error_message_for_invalid_smell_type(key)) unless smell_type?(key)
          hash[Reek::Smells.const_get(key)] = value
        end
      end

      def best_directory_match_for(source_base_dir)
        directory_directives.
          keys.
          select { |pathname| source_base_dir.to_s =~ /#{pathname}/ }.
          max_by { |pathname| pathname.to_s.length }
      end

      def smell_type?(key)
        Reek::Smells.const_get key
      rescue NameError
        false
      end

      def error_message_for_invalid_smell_type(klass)
        "You are trying to configure smell type #{klass} but we can't find one with that name.\n" \
          "Please make sure you spelled it right (see 'config/defaults.reek' in the reek\n" \
          'repository for a list of all available smell types.'
      end

      def error_message_for_missing_directory(pathname)
        "Configuration error: Directory `#{pathname}` does not exist"
      end

      def error_message_for_file_given(pathname)
        "Configuration error: `#{pathname}` is supposed to be a directory but is a file"
      end

      def validate_directive(pathname)
        abort(error_message_for_missing_directory(pathname)) unless pathname.exist?
        abort(error_message_for_file_given(pathname)) unless pathname.directory?
      end
    end
  end
end
