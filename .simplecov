# frozen_string_literal: true

SimpleCov.configure do
  cover 'lib/**/*.rb'
  skip 'lib/reek/version.rb' # version.rb is loaded too early to test
  skip 'lib/reek/cli/options.rb' # tested mostly via integration tests
  coverage_dir 'tmp/coverage'
  enable_coverage :branch

  unless RUBY_ENGINE == 'jruby'
    minimum_coverage 98.88
    coverage(:line) { minimum_per_file 81.4 }
  end
end
