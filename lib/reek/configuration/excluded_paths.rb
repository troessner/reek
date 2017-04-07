# frozen_string_literal: true

require_relative './configuration_validator'

module Reek
  module Configuration
    #
    # Array extension for excluded paths.
    #
    module ExcludedPaths
      include ConfigurationValidator

      # :reek:NestedIterators: { max_allowed_nesting: 2 }
      def add(paths)
        paths.each do |path|
          with_valid_directory(path) { |directory| self << directory }
        end
      end
    end
  end
end
