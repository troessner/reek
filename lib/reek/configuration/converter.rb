# frozen_string_literal: true

require_relative './configuration_validator'

module Reek
  module Configuration
    # Responsible for converting configuration values coming from the outside world
    # to whatever we want to use internally.
    module Converter
      class << self
        REGEXABLE_ATTRIBUTES = %w(accept reject exclude).freeze
        include ConfigurationValidator

        # @param configuration [Hash] e.g.
        # {
        #   "UnusedPrivateMethod" => {"exclude"=>["/exclude regexp/"]},
        #   "UncommunicativeMethodName"=>{"reject"=>["reject name"], "accept"=>["accept name"]
        # }
        # @return [Hash]
        #
        # @quality :reek:NestedIterators { max_allowed_nesting: 3 }
        # @quality :reek:DuplicateMethodCall { max_calls: 3 }
        # @quality :reek:TooManyStatements { max_statements: 7 }
        def strings_to_regexes(configuration)
          configuration.keys.
            select { |key| smell_type?(key) }.
            each do |detector|
              (configuration[detector].keys & REGEXABLE_ATTRIBUTES).each do |attribute|
                configuration[detector][attribute] = configuration[detector][attribute].map do |item|
                  marked_as_regex?(item) ? Regexp.new(item[1..-2]) : item
                end
              end
            end
          configuration
        end

        # @param configuration [Hash] e.g.
        #   {"enabled"=>true, "exclude"=>[], "reject"=>[/^[a-z]$/, /[0-9]$/, /[A-Z]/], "accept"=>[]}
        # @return [Hash]
        #
        # @quality :reek:NestedIterators { max_allowed_nesting: 2 }
        def regexes_to_strings(configuration)
          (configuration.keys & REGEXABLE_ATTRIBUTES).each do |attribute|
            configuration[attribute] = configuration[attribute].map do |item|
              item.is_a?(Regexp) ? item.inspect : item
            end
          end
          configuration
        end

        def marked_as_regex?(string)
          string.start_with?('/') && string.end_with?('/')
        end
      end
    end
  end
end
