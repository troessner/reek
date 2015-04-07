require_relative '../lib/reek/rake/task'

Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.verbose = false
end
