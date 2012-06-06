require 'rake/clean'
require "bundler/gem_tasks"

$:.unshift File.dirname(__FILE__) + '/lib'

PROJECT_NAME = 'reek'

BUILD_DIR = 'build'; directory BUILD_DIR
PKG_DIR = "#{BUILD_DIR}/pkg"; directory PKG_DIR

GEM_MANIFEST = "Manifest.txt"
VERSION_FILE = 'lib/reek.rb'

CLOBBER.include("#{BUILD_DIR}/*")

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:test]

