# frozen_string_literal: true

module Reek
  module Report
    # loads the smell type metadata to present in Code Climate
    module CodeClimateConfiguration
      def self.load
        config_file = File.expand_path('../code_climate_configuration.yml', __FILE__)
        YAML.load_file config_file
      end
    end
  end
end
