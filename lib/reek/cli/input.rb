require_relative '../source/source_locator'

module Reek
  module CLI
    #
    # CLI Input utility
    #
    # @api private
    module Input
      def sources
        if no_source_files_given?
          if input_was_piped?
            source_from_pipe
          else
            working_directory_as_source
          end
        else
          sources_from_argv
        end
      end

      private

      def input_was_piped?
        !$stdin.tty?
      end

      def no_source_files_given?
        # At this point we have deleted all options from argv. The only remaining entries
        # are paths to the source files. If argv is empty, this means that no files were given.
        argv.empty?
      end

      def working_directory_as_source
        Source::SourceLocator.new(['.']).sources
      end

      def sources_from_argv
        Source::SourceLocator.new(argv).sources
      end

      def source_from_pipe
        [$stdin]
      end
    end
  end
end
