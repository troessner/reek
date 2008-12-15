namespace 'git' do

  task 'github' do
    `git push origin`
  end

  desc 'push to bytemark for cruisecontrol build'
  task 'bytemark' do
    `git push bytemark`
  end

  task 'rubyforge' do
    `git push rubyforge`
  end

  desc 'push the current master to all remotes'
  task 'push' => ['bytemark', 'github', 'rubyforge']

end
