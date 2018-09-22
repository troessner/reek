require_relative '../lib/reek'
require_relative '../lib/reek/detector_repository'
require_relative '../lib/reek/configuration/rake_task_converter'
require_relative '../lib/reek/configuration/app_configuration'

require 'yaml'

namespace :configuration do
  desc 'Updates the default configuration file when smell defaults change'
  task :update_default_configuration do
    DEFAULT_SMELL_CONFIGURATION = 'docs/defaults.reek.yml'.freeze
    content = Reek::DetectorRepository.smell_types.each_with_object({}) do |klass, hash|
      hash[klass.smell_type] = Reek::Configuration::RakeTaskConverter.convert klass.default_config
    end
    File.open(DEFAULT_SMELL_CONFIGURATION, 'w') do |file|
      YAML.dump({ Reek::DETECTORS_KEY => content }, file)
    end
  end
end
