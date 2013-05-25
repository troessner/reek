require 'reek/core/code_parser'
require 'reek/core/smell_repository'
require 'reek/source/config_file'

module Reek
  module Core

    #
    # Configures all available smell detectors and applies them to a source.
    #
    class Sniffer

      def initialize(src, extra_config_files = [], smell_repository=Core::SmellRepository.new(src.desc))
        @smell_repository = smell_repository
        @source = src

        config_files = extra_config_files + @source.relevant_config_files
        config_files.each{ |cf| Reek::Source::ConfigFile.new(cf).configure(@smell_repository) }
      end

      def report_on(listener)
        CodeParser.new(@smell_repository).process(@source.syntax_tree)
        @smell_repository.report_on(listener)
      end

      def examine(scope, node_type)
        @smell_repository.examine scope, node_type
      end
    end
  end
end
