$:.unshift File.dirname(__FILE__) + '/../lib'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'reek/spec'
