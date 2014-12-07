require 'rake/clean'

CONFIG_FILE = 'config/defaults.reek'

file CONFIG_FILE do
  config = {}
  require 'reek/core/sniffer'
  Reek::Core::SmellRepository.smell_types.each do |klass|
    config[klass.name.split(/::/)[-1]] = klass.default_config
  end
  $stderr.puts "Creating #{CONFIG_FILE}"
  require 'yaml'
  File.open(CONFIG_FILE, 'w') { |f| YAML.dump(config, f) }
end

task CONFIG_FILE => FileList['lib/reek/smells/*.rb']

task 'test:spec' => CONFIG_FILE
task 'test:quality' => CONFIG_FILE
task 'test:features' => CONFIG_FILE
task 'reek' => CONFIG_FILE
