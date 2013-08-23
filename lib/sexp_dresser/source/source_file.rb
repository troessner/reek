require 'sexp_dresser/source/source_code'

module SexpDresser
  module Source

    #
    # Represents a file of Ruby source, whose contents will be examined
    # for code smells.
    #
    class SourceFile < SourceCode

      def initialize(path)
        @path = path
        super(IO.readlines(@path).join, @path)
      end

      def configure(analyzer)
        path = File.expand_path(File.dirname(@path))
        all_config_files(path).each { |cf| ConfigFile.new(cf).configure(analyzer) }
      end

    private

      def all_config_files(path)
        return [] unless File.exist?(path)
        parent = File.dirname(path)
        return [] if path == parent
        all_config_files(parent) + Dir["#{path}/*.sexp_dresser", "#{path}/.sexp_dresser"]
      end
    end
  end
end
