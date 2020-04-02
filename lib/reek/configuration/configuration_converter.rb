# frozen_string_literal: true

require_relative './configuration_validator'

module Reek
  module Configuration
    # Responsible for converting marked strings coming from the outside world
    # into proper regexes.
    class ConfigurationConverter
      REGEXABLE_ATTRIBUTES = %w(accept reject exclude).freeze
      include ConfigurationValidator
      attr_reader :configuration

      # @param configuration [Hash] e.g.
      #
      #   detectors => {
      #     "UnusedPrivateMethod" => {"exclude"=>["/exclude regexp/"]},
      #     "UncommunicativeMethodName"=>{"reject"=>["reject name"], "accept"=>["accept name"]
      #   },
      #   directories => {
      #     "app/controllers" => {
      #       "UnusedPrivateMethod" => {"exclude"=>["/exclude regexp/"]},
      #       "UncommunicativeMethodName"=>{"reject"=>["reject name"], "accept"=>["accept name"]}
      #     }
      #   }
      def initialize(configuration)
        @configuration = configuration
      end

      # Converts all marked strings across the whole configuration to regexes.
      # @return [Hash]
      #
      def convert
        strings_to_regexes_for_detectors
        strings_to_regexes_for_directories

        configuration
      end

      private

      # @param value [String] String that is potentially marked as regex, e.g. "/foobar/".
      # @return [Bool] if the string in question is marked as regex.
      #
      # @quality :reek:UtilityFunction
      def marked_as_regex?(value)
        value.start_with?('/') && value.end_with?('/')
      end

      # @param value [value] String that is potentially marked as regex, e.g. "/foobar/".
      # @return [Regexp] e.g. /foobar/.
      #
      def to_regex(value)
        marked_as_regex?(value) ? Regexp.new(value[1..-2]) : value
      end

      # @param detector_configuration [Hash] e.g.
      #   { "UnusedPrivateMethod" => {"exclude"=>["/exclude regexp/"] }
      # @return [Array] all the attributes from the detector configuration that potentially contain regexes.
      #   Using this example above this would just be "exclude".
      #
      # @quality :reek:UtilityFunction
      def convertible_attributes(detector_configuration)
        detector_configuration.keys & REGEXABLE_ATTRIBUTES
      end

      # Iterates over our detector configuration and converts all marked strings into regexes.
      # @return nil
      #
      # @quality :reek:DuplicateMethodCall { max_calls: 3 }
      # @quality :reek:NestedIterators { max_allowed_nesting: 3 }
      # @quality :reek:TooManyStatements { max_statements: 6 }
      def strings_to_regexes_for_detectors
        return unless configuration[DETECTORS_KEY]

        configuration[DETECTORS_KEY].tap do |detectors|
          detectors.each_key do |detector|
            convertible_attributes(detectors[detector]).each do |attribute|
              detectors[detector][attribute] = detectors[detector][attribute].map do |item|
                to_regex item
              end
            end
          end
        end
      end

      # Iterates over our directory configuration and converts all marked strings into regexes.
      # @return nil
      #
      # @quality :reek:DuplicateMethodCall { max_calls: 3 }
      # @quality :reek:NestedIterators { max_allowed_nesting: 4 }
      # @quality :reek:TooManyStatements { max_statements: 7 }
      def strings_to_regexes_for_directories
        return unless configuration[DIRECTORIES_KEY]

        configuration[DIRECTORIES_KEY].tap do |directories|
          directories.each_key do |directory|
            directories[directory].each do |detector, configuration|
              convertible_attributes(configuration).each do |attribute|
                directories[directory][detector][attribute] = directories[directory][detector][attribute].map do |item|
                  to_regex item
                end
              end
            end
          end
        end
      end
    end
  end
end
