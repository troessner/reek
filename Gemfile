source 'https://rubygems.org'

# The gem's dependencies are specified in the gemspec
gemspec

group :local_development do
  gem 'pry'
  platforms :mri do
    if RUBY_VERSION >= '2.0.0'
      gem 'byebug'
      gem 'pry-byebug'
    end
  end
end
