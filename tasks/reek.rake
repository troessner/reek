require 'reek/rake_task'

Reek::RakeTask.new do |t|
  t.fail_on_error = true
  t.verbose = false
#  t.sort = 'smell'
end
