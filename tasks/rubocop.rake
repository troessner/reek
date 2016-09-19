begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new do |task|
    task.options << '--display-cop-names'
  end
rescue LoadError
  task :rubocop do
    puts 'Install rubocop to run its rake tasks'
  end
end
