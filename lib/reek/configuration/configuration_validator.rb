# frozen_string_literal: true

require_relative '../errors/config_file_error'

module Reek
  module Configuration
    #
    # Configuration validator module.
    #
    module ConfigurationValidator
      private

      # @quality :reek:UtilityFunction
      def smell_type?(key)
        Reek::SmellDetectors.const_defined? key
      rescue NameError
        false
      end

      # @quality :reek:UtilityFunction
      def key_to_smell_detector(key)
        Reek::SmellDetectors.const_get key
      end

      def with_valid_directory(path)
        directory = Pathname.new path.to_s.chomp('/')
        if directory.file?
          raise Errors::ConfigFileError,
                "`#{directory}` is supposed to be a directory but is a file"
        end
        yield directory if block_given?
      end
    end
  end
end
