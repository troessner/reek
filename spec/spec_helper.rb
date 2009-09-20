$:.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
gem 'rspec'
require 'spec'

require 'reek/adapters/spec'

SAMPLES_DIR = 'spec/samples' unless Object.const_defined?('SAMPLES_DIR')
