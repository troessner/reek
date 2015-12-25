desc 'Starts the interactive console'
task :console do
  require 'pry'
  Pry.start
end
