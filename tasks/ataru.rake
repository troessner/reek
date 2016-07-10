desc 'Runs ataru to check if our docs are still in sync with our code'
task :ataru do
  system 'bundle exec ataru check'
  abort unless $CHILD_STATUS.success?
end
