namespace :git do

  desc 'push the current master to all github'
  task :github do
    `git push origin`
  end

  desc 'push the current master to rubyforge.org'
  task :rubyforge do
    `git push rubyforge`
  end

  desc 'push the current master to all remotes'
  task :push => [:github, :rubyforge]

end
