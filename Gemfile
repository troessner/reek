source 'https://rubygems.org'

gemspec

group :development do
  gem 'aruba',         '~> 0.10.0'
  gem 'ataru',         '~> 0.2.0'
  gem 'cucumber',      '~> 2.0'
  gem 'factory_girl',  '~> 4.0'
  gem 'rake',          '~> 10.0'
  gem 'rspec',         '~> 3.0'
  gem 'rubocop',       '~> 0.34.0'
  gem 'yard',          '~> 0.8.7'

  platforms :mri do
    gem 'redcarpet', '~> 3.3.1'
  end
end

group :debugging do
  gem 'pry'
  platforms :mri do
    gem 'pry-byebug'
    gem 'pry-stack_explorer'
  end
end
