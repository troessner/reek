namespace :git do

  desc 'push the current master to all remotes'
  task :push do
    `git push origin`
    `git push rubyforge`
  end

end
