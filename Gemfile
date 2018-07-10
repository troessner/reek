source 'https://rubygems.org'

gemspec

ruby RUBY_VERSION

group :development do
  gem 'activesupport', '>= 4.2'
  gem 'aruba',         '~> 0.14.0'
  gem 'ataru',         '~> 0.2.0'
  gem 'cucumber',      '~> 3.0'
  gem 'factory_bot',   '~> 4.0'
  gem 'rake',          '~> 12.0'
  gem 'rspec',         '~> 3.0'
  gem 'rspec-benchmark'
  gem 'rubocop',       '~> 0.57.1'
  gem 'rubocop-rspec', '~> 1.20'
  gem 'ruby-prof'
  gem 'simplecov',     '~> 0.16.1'
  gem 'stackprof',     '~> 0.2.1'
  gem 'yard',          '~> 0.9.5'

  platforms :mri do
    gem 'redcarpet', '~> 3.4.0'
  end
end

group :debugging do
  # Fixing https://github.com/guard/guard/wiki/Add-Readline-support-to-Ruby-on-Mac-OS-X#option-4-using-a-pure-ruby-readline-implementation
  gem 'pry'
  gem 'rb-readline', '~> 0.5.3'
  platforms :mri do
    gem 'pry-byebug'
    gem 'pry-stack_explorer'
  end
end
