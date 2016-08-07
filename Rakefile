require 'bundler/gem_tasks'
require 'rake/clean'

Dir['tasks/**/*.rake'].each { |t| load t }

task local_test_run: [:test, :rubocop, 'test:quality']
task ci: [:test, :rubocop, 'test:quality', :ataru]
task default: :local_test_run
