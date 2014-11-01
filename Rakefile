require 'rake/clean'
require 'bundler/gem_tasks'

Dir['tasks/**/*.rake'].each { |t| load t }

task default: [:test]

require 'rubocop/rake_task'
RuboCop::RakeTask.new
