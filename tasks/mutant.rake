desc 'Runs mutant'
task :mutant do
  system 'RUBY_THREAD_VM_STACK_SIZE=64000 bundle exec mutant --include lib '\
         "--require reek --use rspec --since master --jobs 4 'Reek*'"
end
