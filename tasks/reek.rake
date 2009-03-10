require 'reek/rake_task'

Reek::RakeTask.new do |t|
  t.fail_on_error = true
  t.verbose = false
#  t.reek_opts = '-f "Smell: %s: %c %w"'
end

begin
  require 'flay'

  desc 'Check for code duplication'
  task 'flay' do
    files = FileList['lib/**/*.rb']
    flayer = Flay.new(16)
    flayer.process(*files)
    flayer.report
  end
rescue LoadError
end
