SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter 'lib/reek/version.rb' # version.rb is loaded too early to test
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  SimpleCov.minimum_coverage 98.9
  SimpleCov.minimum_coverage_by_file 81.4
end
