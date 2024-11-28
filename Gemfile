source 'https://rubygems.org'

gemspec

ruby RUBY_VERSION

group :development do
  gem 'aruba',                 '~> 2.1'
  gem 'codeclimate-engine-rb', '~> 0.4.0'
  gem 'cucumber',              '~> 9.0'
  gem 'kramdown',              '~> 2.1'
  gem 'kramdown-parser-gfm',   '~> 1.0'
  gem 'rake',                  '~> 13.0'
  gem 'rspec',                 '~> 3.0'
  gem 'rspec-benchmark',       '~> 0.6.0'
  gem 'rubocop',               '~> 1.69.0'
  gem 'rubocop-performance',   '~> 1.23.0'
  gem 'rubocop-rspec',         '~> 3.2.0'
  gem 'simplecov',             '~> 0.22.0'
  gem 'yard',                  '~> 0.9.5'

  platforms :mri do
    # Needed for YARD to properly parse GFM code blocks in the documentation
    gem 'redcarpet', '~> 3.4'
  end
end
