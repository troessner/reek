# frozen_string_literal: true

require_relative './configuration_validator'

module Reek
  module Configuration
    #
    # Hash extension for the default directive.
    #
    module DefaultDirective
      include ConfigurationValidator

      def add(key, config)
        detector = key_to_smell_detector(key)
        self[detector] = (self[detector] || {}).merge config
      end
    end
  end
end
