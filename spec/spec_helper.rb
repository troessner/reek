
require 'rubygems'
begin
  require 'spec/expectations'
rescue LoadError
  gem 'rspec'
  require 'spec/expectations'
end

require 'spec/autorun'

require File.join((File.dirname(File.dirname(File.expand_path(__FILE__)))), 'lib', 'reek', 'spec')

SAMPLES_DIR = 'spec/samples' unless Object.const_defined?('SAMPLES_DIR')
