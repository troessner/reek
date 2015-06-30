source 'https://rubygems.org'

# The gem's dependencies are specified in the gemspec
gemspec

group :local_development do
  gem 'pry'
  gem 'yard', '~> 0.8.7'

  platforms :mri do
    gem 'pry-byebug'
    gem 'pry-stack_explorer'

    gem 'redcarpet', '~> 3.3.1'
  end
end
