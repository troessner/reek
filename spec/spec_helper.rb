$:.unshift File.dirname(__FILE__) + '/../lib'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'reek'
require 'reek/spec'

Spec::Runner.configure do |config|
  config.include(Reek::Spec)
end
