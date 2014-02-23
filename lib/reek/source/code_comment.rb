
module Reek
  module Source

    #
    # A comment header from an abstract syntax tree; found directly above
    # module, class and method definitions.
    #
    class CodeComment
      CONFIG_REGEX = /:reek:(\w+)(:\s*\{.*?\})?/

      def initialize(text)
        @config =  Hash.new { |hash,key| hash[key] = {} }
        @text = text.gsub(CONFIG_REGEX) do
          add_to_config($1, $2)
          ''
        end.gsub(/#/, '').gsub(/\n/, '').strip
      end

      def config
        @config
      end

      def is_descriptive?
        @text.split(/\s+/).length >= 2
      end

    protected
      def add_to_config(smell, options)
        options ||= ': { enabled: false }'
        @config.merge! YAML.load(smell.gsub(/(?:^|_)(.)/) { $1.upcase } + options)
        # extend this to all configs --------------------------^
        # extend to allow configuration of whole smell class, not just subclass
      end
    end
  end
end
