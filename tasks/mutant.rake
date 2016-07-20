desc 'Runs mutant'
task :mutant do
  command = <<-EOS
    RUBY_THREAD_VM_STACK_SIZE=64000\
    bundle exec mutant\
      --include lib\
      --require reek\
      --use rspec\
      --since master^\
      --jobs 4 'Reek*'
  EOS
  system command
  abort unless $CHILD_STATUS.success?
end
