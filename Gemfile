source 'https://rubygems.org'

gemspec

ruby RUBY_VERSION

group :development do
  gem 'aruba',               '~> 0.14.8'
  gem 'cucumber',            '~> 3.0'
  gem 'factory_bot',         '~> 5.0', '!= 5.1.0'
  gem 'kramdown',            '~> 2.1'
  gem 'kramdown-parser-gfm', '~> 1.0'
  gem 'rake',                '~> 13.0'
  gem 'rspec',               '~> 3.0'
  gem 'rspec-benchmark',     '~> 0.5.0'
  gem 'rubocop',             '~> 0.75.0'
  gem 'rubocop-performance', '~> 1.5.0'
  gem 'rubocop-rspec',       '~> 1.36.0'
  gem 'simplecov',           '~> 0.17.0'
  gem 'yard',                '~> 0.9.5'

  platforms :mri do
    gem 'redcarpet', '~> 3.4'
  end
end

group :debugging do
  gem 'pry'
  platforms :mri do
    gem 'pry-byebug'
  end
end
