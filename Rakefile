require 'fileutils'
include FileUtils

$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

Dir['tasks/**/*.rake'].each { |rake| load rake }

task :default => :spec
