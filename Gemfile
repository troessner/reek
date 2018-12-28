source 'https://rubygems.org'

gemspec

ruby RUBY_VERSION

group :development do
  gem 'aruba',           '~> 0.14.0'
  gem 'cucumber',        '~> 3.0'
  gem 'factory_bot',     '~> 4.0'
  gem 'kramdown',        '~> 1.17'
  gem 'rake',            '~> 12.0'
  gem 'rspec',           '~> 3.0'
  gem 'rspec-benchmark', '~> 0.4.0'
  gem 'rubocop',         '~> 0.61.1'
  gem 'rubocop-rspec',   '~> 1.30.1'
  gem 'simplecov',       '~> 0.16.1'
  gem 'yard',            '~> 0.9.5'

  platforms :mri do
    gem 'redcarpet', '~> 3.4.0'
  end
end

group :debugging do
  gem 'pry'
  platforms :mri do
    gem 'pry-byebug'
  end
end
