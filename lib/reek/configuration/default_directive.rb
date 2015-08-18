module Reek
  module Configuration
    #
    # Hash extension for the default directive.
    #
    module DefaultDirective
      def add(key, config)
        self[Reek::Smells.const_get(key)] = config
      end
    end
  end
end
