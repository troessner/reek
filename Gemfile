source 'https://rubygems.org'

gemspec

ruby RUBY_VERSION

group :development do
  gem 'aruba',                 '~> 2.1'
  gem 'codeclimate-engine-rb', '~> 0.4.0'
  gem 'cucumber',              '~> 8.0'
  gem 'kramdown',              '~> 2.1'
  gem 'kramdown-parser-gfm',   '~> 1.0'
  gem 'rake',                  '~> 13.0'
  gem 'rspec',                 '~> 3.0'
  gem 'rspec-benchmark',       '~> 0.6.0'
  gem 'rubocop',               '~> 1.31.0'
  gem 'rubocop-performance',   '~> 1.14.0'
  gem 'rubocop-rspec',         '~> 2.12.1'
  gem 'simplecov',             ['>= 0.18.0', '< 0.22.0']
  gem 'yard',                  '~> 0.9.5'

  platforms :mri do
    gem 'redcarpet', '~> 3.4'
  end
end

group :debugging do
  gem 'pry', '~> 0.14.0'
end
