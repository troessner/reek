$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
begin
  require 'spec/expectations'
rescue LoadError
  gem 'rspec'
  require 'spec/expectations'
end

require 'spec/autorun'

require 'reek/adapters/spec'

SAMPLES_DIR = 'spec/samples' unless Object.const_defined?('SAMPLES_DIR')
