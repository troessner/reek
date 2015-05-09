require 'yaml'

module Reek
  module Core
    #
    # A comment header from an abstract syntax tree; found directly above
    # module, class and method definitions.
    #
    class CodeComment
      CONFIG_REGEX = /:reek:(\w+)(:\s*\{.*?\})?/

      def initialize(text)
        @text = text.gsub(CONFIG_REGEX) do
          add_to_config($1, $2)
          ''
        end.gsub(/#/, '').gsub(/\n/, '').strip
      end

      def config
        @config ||= Hash.new { |hash, key| hash[key] = {} }
      end

      def descriptive?
        @text.split(/\s+/).length >= 2
      end

      protected

      def add_to_config(smell, options)
        options ||= ': { enabled: false }'
        config.merge! YAML.load(smell.gsub(/(?:^|_)(.)/) { $1.upcase } + options)
        # TODO: extend this to all configs -------------------^
        # TODO: extend to allow configuration of whole smell class, not just subclass
      end
    end
  end
end
