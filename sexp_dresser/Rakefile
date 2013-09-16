require 'rake/clean'
require "bundler/gem_tasks"

$:.unshift File.dirname(__FILE__) + '/lib'

PROJECT_NAME = 'sexp_dresser'

BUILD_DIR = 'build'; directory BUILD_DIR
PKG_DIR = "#{BUILD_DIR}/pkg"; directory PKG_DIR

GEM_MANIFEST = "Manifest.txt"
VERSION_FILE = 'lib/sexp_dresser.rb'

CLOBBER.include("#{BUILD_DIR}/*")

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:test]

