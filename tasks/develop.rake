require 'rake/clean'
require 'reek/smells/smells'
require 'yaml'

CONFIG_DIR = 'config'

CLOBBER.include(CONFIG_DIR)

directory CONFIG_DIR

desc 'creates the default config file'
task 'mkconfig' => [CONFIG_DIR] do
  config = {}
  Reek::SmellConfig::SMELL_CLASSES.each do |klass|
    config[klass.name.split(/::/)[-1]] = klass.default_config
  end
  File.open("#{CONFIG_DIR}/defaults.reek", 'w') { |f| YAML.dump(config, f) }
end

namespace 'git' do

  task 'github' do
    `git push origin`
  end

  task 'rubyforge' do
    `git push rubyforge`
  end

  desc 'push the current master to all remotes'
  task 'push' => ['github', 'rubyforge']
end

desc 'runs the unit and integration tests'
task 'cruise' => %w{clobber mkconfig rspec:all}

task 'spec' => ['mkconfig']
