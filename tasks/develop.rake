require 'rake/clean'
require 'reek/smells/smells'
require 'yaml'

CONFIG_DIR = 'config'
CONFIG_FILE = "#{CONFIG_DIR}/defaults.reek"

CLOBBER.include(CONFIG_DIR)

directory CONFIG_DIR

desc 'creates the default config file'
file CONFIG_FILE => [CONFIG_DIR] do
  config = {}
  Reek::SmellConfig::SMELL_CLASSES.each do |klass|
    config[klass.name.split(/::/)[-1]] = klass.default_config
  end
  $stderr.puts "Creating #{CONFIG_FILE}"
  File.open(CONFIG_FILE, 'w') { |f| YAML.dump(config, f) }
end

task CONFIG_FILE => FileList['lib/reek/smells/*.rb']

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

task :release_notes do
  puts "1) git commit -m \"Release #{Reek::VERSION}\""
  puts "2) git tag -a \"v#{Reek::VERSION}\" -m \"Release #{Reek::VERSION}\""
  puts "3) git push"
  puts "4) git push --tags"
end

task :gemspec => :release_notes

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

desc 'runs the unit and integration tests'
task 'cruise' => ['clobber', 'rspec:all']

task 'rspec:fast' => [CONFIG_FILE]
task 'rspec:all' => [CONFIG_FILE]
task 'reek' => [CONFIG_FILE]
