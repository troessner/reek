# frozen_string_literal: true

desc 'Starts the interactive console'
task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end
