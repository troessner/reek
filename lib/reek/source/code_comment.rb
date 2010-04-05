
module Reek
  module Source

    #
    # A comment header from an abstract syntax tree; found directly above
    # module, class and method definitions.
    #
    class CodeComment

      def initialize(text)
        @config =  Hash.new { |hash,key| hash[key] = {} }
        @text = text.gsub(/:reek:\s*(.*)\s*$/) { |m| @config.merge! YAML.load($1); '' }.gsub(/#/, '').gsub(/\n/, '').strip
      end

      def config
        @config
      end

      def is_descriptive?
        @text.split(/\s+/).length >= 2
      end
    end
  end
end
