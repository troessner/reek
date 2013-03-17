require 'rake/clean'
require 'reek/core/sniffer'
require 'yaml'

CONFIG_DIR = 'config'
CONFIG_FILE = "#{CONFIG_DIR}/defaults.reek"

CLOBBER.include(CONFIG_DIR)

directory CONFIG_DIR

file CONFIG_FILE => [CONFIG_DIR] do
  config = {}
  Reek::Core::SmellRepository.smell_classes.each do |klass|
    config[klass.name.split(/::/)[-1]] = klass.default_config
  end
  $stderr.puts "Creating #{CONFIG_FILE}"
  File.open(CONFIG_FILE, 'w') { |f| YAML.dump(config, f) }
end

task CONFIG_FILE => FileList['lib/reek/smells/*.rb']

task 'test:spec' => [CONFIG_FILE]
task 'test:slow' => [CONFIG_FILE]
task 'test:rcov' => [CONFIG_FILE]
task 'test:quality' => [CONFIG_FILE]
task 'test:features' => [CONFIG_FILE]
task 'reek' => [CONFIG_FILE]
task 'check:manifest' => [CONFIG_FILE]
