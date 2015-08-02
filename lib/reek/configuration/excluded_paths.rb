require_relative './configuration_validator'

module Reek
  module Configuration
    #
    # Hash extension for excluded paths.
    #
    module ExcludedPaths
      include ConfigurationValidator

      def add(paths)
        paths.each do |path|
          with_valid_directory(path) { |directory| self << directory }
        end
      end
    end
  end
end
