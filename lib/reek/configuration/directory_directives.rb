# frozen_string_literal: true

require_relative './configuration_validator'

module Reek
  module Configuration
    #
    # Hash extension for directory directives.
    #
    module DirectoryDirectives
      include ConfigurationValidator

      # Returns the directive for a given source.
      #
      # @param source_via [String] the source of the code inspected
      #
      # @return [Hash | nil] the configuration for the source or nil
      def directive_for(source_via)
        return unless source_via

        source_base_dir = Pathname.new(source_via).dirname
        hit = best_match_for source_base_dir
        self[hit]
      end

      # Adds a directive and returns self.
      #
      # @param directory_config [Hash] the configuration e.g.:
      #   {
      #    "samples/two_smelly_files" => {:IrresponsibleModule=>{:enabled=>false}},
      #    "samples/three_clean_files" => {:Attribute=>{:enabled=>true}}
      #   }
      #
      # @return [self]
      #
      # @quality :reek:NestedIterators { max_allowed_nesting: 3 }
      # @quality :reek:TooManyStatements { max_statements: 6 }
      def add(directory_config)
        directory_config.each do |path, detector_config|
          with_valid_directory(path) do |directory|
            self[directory] = detector_config.each_with_object({}) do |(key, value), hash|
              abort(error_message_for_invalid_smell_type(key)) unless smell_type?(key)
              hash[key_to_smell_detector(key)] = value
            end
          end
        end
        self
      end

      private

      # @quality :reek:DuplicateMethodCall { max_calls: 2 }
      # @quality :reek:FeatureEnvy
      def best_match_for(source_base_dir)
        keys.
          select do |pathname|
            match?(source_base_dir, pathname) || match?(source_base_dir, pathname.expand_path)
          end.
          max_by { |pathname| pathname.to_s.length }
      end

      def match?(source_base_dir, pathname)
        source_base_dir.to_s.match(glob_to_regexp(pathname.to_s))
      end

      # Transform a glob pattern to a regexp.
      #
      # It changes:
      # - /** to .*,
      # - ** to .*,
      # - * to [^\/]*.
      #
      # @quality :reek:FeatureEnvy
      # @quality :reek:UtilityFunction
      def glob_to_regexp(glob)
        is_glob_pattern = glob.include?('*')

        regexp = if is_glob_pattern
                   glob.
                     gsub(%r{/\*\*$}, '<<to_eol_wildcards>>').
                     gsub('**', '<<to_wildcards>>').
                     gsub('*', '[^/]*').
                     gsub('.', '\.').
                     gsub('<<to_eol_wildcards>>', '.*').
                     gsub('<<to_wildcards>>', '.*')
                 else
                   "#{glob}.*"
                 end

        Regexp.new("^#{regexp}$", Regexp::IGNORECASE)
      end

      def error_message_for_invalid_smell_type(klass)
        "You are trying to configure smell type #{klass} but we can't find one with that name.\n" \
          "Please make sure you spelled it right. (See 'docs/defaults.reek.yml' in the Reek\n" \
          'repository for a list of all available smell types.)'
      end
    end
  end
end
