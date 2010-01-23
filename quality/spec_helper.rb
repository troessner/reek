$:.unshift File.dirname(__FILE__) + '/../lib'

begin
  require 'spec/expectations'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec/expectations'
end

require 'spec/autorun'

require 'reek/spec'

SAMPLES_DIR = 'spec/samples' unless Object.const_defined?('SAMPLES_DIR')
