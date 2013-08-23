require 'sexp_dresser/source/source_repository'
require 'sexp_dresser/core/code_parser'
module SexpDresser
  class Examiner
    DemoExaminer = Struct.new(:scope, :node_type) do
      def examine(scope, node_type)
        p [scope.name, node_type]
      end
    end


    attr_reader :description, :sources, :examiner

    def initialize(source, examiner=DemoExaminer.new)
       @sources = SexpDresser::Source::SourceRepository.parse(source)
       @description = sources.description
       @examiner = examiner
    end

    def self.from_paths(paths)
       SexpDresser::Source::SourceLocator.new(Array(paths)).all_sources.each do |sources|
         new(sources).process
       end
    end

    def process
      sources.each do |src|
        parser = SexpDresser::Core::CodeParser.new(self)
        parser.process(src.syntax_tree)
      end
    end

    def examine(scope, node_type)
       @examiner.examine scope, node_type
    end

  end
end
