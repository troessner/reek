begin
  require 'reek/adapters/rake_task'

  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.reek_opts = '--quiet --show-all'
  end
rescue Gem::LoadError
end

begin
  require 'metric_fu'
rescue LoadError
end
