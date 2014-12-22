require 'reek/core/code_parser'
require 'reek/core/smell_repository'
require 'reek/configuration/app_configuration'

module Reek
  module Core
    #
    # Configures all available smell detectors and applies them to a source.
    #
    class Sniffer
      def initialize(source, # Either Source::SourceFile or Source::SourceCode
                     smell_repository = Core::SmellRepository.new(source.desc))
        @smell_repository = smell_repository
        @source = source

        Configuration::AppConfiguration.configure_smell_repository(@smell_repository)
      end

      def report_on(listener)
        CodeParser.new(@smell_repository).process(syntax_tree) if syntax_tree
        @smell_repository.report_on(listener)
      end

      def examine(scope, node_type)
        @smell_repository.examine scope, node_type
      end

      private

      def syntax_tree
        @syntax_tree ||= @source.syntax_tree
      end
    end
  end
end
