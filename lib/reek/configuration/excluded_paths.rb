# frozen_string_literal: true

require_relative './configuration_validator'
require_relative '../errors/config_file_error'

module Reek
  module Configuration
    #
    # Array extension for excluded paths.
    #
    module ExcludedPaths
      include ConfigurationValidator

      # @param paths [String]
      # @return [undefined]
      def add(paths)
        paths.flat_map { |path| Dir[path] }.
          each { |path| self << Pathname(path) }
      end
    end
  end
end
