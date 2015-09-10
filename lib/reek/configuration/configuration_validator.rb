module Reek
  module Configuration
    #
    # Configuration validator module.
    #
    module ConfigurationValidator
      private

      # :reek:UtilityFunction
      def smell_type?(key)
        Reek::Smells.const_get key
      rescue NameError
        false
      end

      def error_message_for_missing_directory(pathname)
        "Configuration error: Directory `#{pathname}` does not exist"
      end

      def error_message_for_file_given(pathname)
        "Configuration error: `#{pathname}` is supposed to be a directory but is a file"
      end

      def validate_directory(pathname)
        abort(error_message_for_missing_directory(pathname)) unless pathname.exist?
        abort(error_message_for_file_given(pathname)) if pathname.file?
      end

      def with_valid_directory(path)
        directory = Pathname.new path.to_s.chomp('/')
        validate_directory directory
        yield directory if block_given?
      end
    end
  end
end
