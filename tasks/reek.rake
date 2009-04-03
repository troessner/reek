require 'reek/rake_task'

Reek::RakeTask.new do |t|
  t.fail_on_error = true
  t.verbose = false
#  t.reek_opts = '-f "Smell: %s: %c %w"'
end
