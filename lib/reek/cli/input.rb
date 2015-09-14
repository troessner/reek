require_relative '../source/locators/collection'
require_relative '../source/locators/path'
require_relative '../source/locators/stdin'
require_relative '../source/source_locator'

module Reek
  module CLI
    #
    # CLI Input utility
    #
    module Input
      def sources
        Source::SourceLocator.build(from_argv || from_pipe || from_working_directory).locate
      end

      private

      def from_argv
        argv if source_files_given?
      end

      def from_pipe
        stdin if input_was_piped?
      end

      def from_working_directory
        '.'
      end

      def source_files_given?
        # At this point we have deleted all options from argv. The only remaining entries
        # are paths to the source files. If argv is empty, this means that no files were given.
        argv.any?
      end

      def input_was_piped?
        !stdin.tty?
      end
    end
  end
end
