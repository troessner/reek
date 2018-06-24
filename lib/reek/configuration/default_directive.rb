# frozen_string_literal: true

require_relative './configuration_validator'

module Reek
  module Configuration
    #
    # Hash extension for the default directive.
    #
    module DefaultDirective
      include ConfigurationValidator

      # Adds the configuration for detectors as default directive.
      #
      # @param detectors_configuration [Hash] the configuration e.g.:
      #   {
      #    :IrresponsibleModule => {:enabled=>false},
      #    :Attribute => {:enabled=>true}
      #   }
      #
      # @return [self]
      def add(detectors_configuration)
        detectors_configuration.each do |name, configuration|
          detector = key_to_smell_detector(name)
          self[detector] = (self[detector] || {}).merge configuration
        end
        self
      end
    end
  end
end
