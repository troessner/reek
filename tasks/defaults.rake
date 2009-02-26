$:.unshift 'lib'

require 'rake/clean'
require 'reek/smells/smells'
require 'yaml'

CONFIG_DIR = 'config'

CLOBBER.include(CONFIG_DIR)

directory CONFIG_DIR

desc "creates the default config file"
task :mkconfig => [CONFIG_DIR] do |t|
  config = {}
  Reek::SmellConfig::SMELL_CLASSES.each do |klass|
    config[klass.name.split(/::/)[-1]] = klass.default_config
  end
  File.open("#{CONFIG_DIR}/defaults.reek", 'w') { |f| YAML.dump(config, f) }
end
