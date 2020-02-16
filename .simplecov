SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter 'lib/reek/version.rb' # version.rb is loaded too early to test
  add_filter 'lib/reek/cli/options.rb' # tested mostly via integration tests
  add_filter 'spec/'
  add_filter 'samples/'
  coverage_dir 'tmp/coverage'
  enable_coverage :branch
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  unless RUBY_ENGINE == 'jruby'
    SimpleCov.minimum_coverage 98.88
    SimpleCov.minimum_coverage_by_file 81.4
  end
end
