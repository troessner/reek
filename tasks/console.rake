desc 'Starts the interactive console'
task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end
