require 'rake/clean'
require 'bundler/gem_tasks'

Dir['tasks/**/*.rake'].each { |t| load t }

task default: [:test, :rubocop]
