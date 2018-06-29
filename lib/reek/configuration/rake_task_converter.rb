# frozen_string_literal: true

module Reek
  module Configuration
    # Responsible for converting configuration values coming from the outside world
    # to whatever we want to use internally.
    module RakeTaskConverter
      class << self
        REGEXABLE_ATTRIBUTES = %w(accept reject exclude).freeze

        # Converts marked strings like "/foobar/" into regexes.
        #
        # @param configuration [Hash] e.g.
        #   {"enabled"=>true, "exclude"=>[], "reject"=>[/^[a-z]$/, /[0-9]$/, /[A-Z]/], "accept"=>[]}
        # @return [Hash]
        #
        # @quality :reek:NestedIterators { max_allowed_nesting: 2 }
        def convert(configuration)
          (configuration.keys & REGEXABLE_ATTRIBUTES).each do |attribute|
            configuration[attribute] = configuration[attribute].map do |item|
              item.is_a?(Regexp) ? item.inspect : item
            end
          end
          configuration
        end
      end
    end
  end
end
