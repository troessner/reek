require 'bundler/gem_tasks'
require 'private_attr/everywhere'
require 'rake/clean'

Dir['tasks/**/*.rake'].each { |t| load t }

task default: :test
task default: :rubocop unless RUBY_ENGINE == 'rbx'
