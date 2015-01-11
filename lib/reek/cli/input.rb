require 'reek/source'

module Reek
  module CLI
    #
    # CLI Input utility
    #
    module Input
      def sources
        if input_was_piped?
          source_from_pipe
        else
          if no_source_files_given?
            working_directory_as_source
          else
            sources_from_argv
          end
        end
      end

      private

      def input_was_piped?
        !$stdin.tty?
      end

      def no_source_files_given?
        # At this point we have deleted all options from @argv. The only remaining entries
        # are paths to the source files. If @argv is empty, this means that no files were given.
        @argv.empty?
      end

      def working_directory_as_source
        Source::SourceLocator.new(['.']).all_sources
      end

      def sources_from_argv
        Source::SourceLocator.new(@argv).all_sources
      end

      def source_from_pipe
        [$stdin.to_reek_source('$stdin')]
      end
    end
  end
end
