require File.join(File.dirname(File.expand_path(__FILE__)), 'code_parser')
require File.join(File.dirname(File.expand_path(__FILE__)), 'smell_repository')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'source', 'config_file')
require 'yaml'
require File.join(File.dirname(File.expand_path(__FILE__)), 'hash_extensions')

module Reek
  module Core

    #
    # Configures all available smell detectors and applies them to a source.
    #
    class Sniffer

      def initialize(src, config_files = [], smell_repository=Core::SmellRepository.new(src.desc))
        @smell_repository = smell_repository
        config_files.each{ |cf| Reek::Source::ConfigFile.new(cf).configure(self) }
        @source = src
        src.configure(self)
      end

      def configure(klass, config)
        @smell_repository.configure klass, config
      end

      def report_on(listener)
        CodeParser.new(self).process(@source.syntax_tree)
        @smell_repository.report_on(listener)
      end

      def examine(scope, node_type)
        @smell_repository.examine scope, node_type
      end
    end
  end
end
