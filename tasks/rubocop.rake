require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.options << '--display-cop-names'
end
