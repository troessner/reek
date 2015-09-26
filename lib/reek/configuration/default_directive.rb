module Reek
  module Configuration
    #
    # Hash extension for the default directive.
    #
    module DefaultDirective
      include ConfigurationValidator

      def add(key, config)
        self[key_to_smell_detector(key)] = config
      end
    end
  end
end
