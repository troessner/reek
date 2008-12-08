namespace :git do

  task :github do
    `git push origin`
  end

  task :rubyforge do
    `git push rubyforge`
  end

  desc 'push the current master to all remotes'
  task :push => [:github, :rubyforge]

end
