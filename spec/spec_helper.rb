$:.unshift File.dirname(__FILE__) + '/../lib'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'reek/spec'

SAMPLES_DIR = 'spec/slow/samples' unless Object.const_defined?('SAMPLES_DIR')
