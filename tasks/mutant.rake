desc 'Runs mutant'
task :mutant do
  command = <<-EOS
    branch_name=$(git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3)
    if [ "$branch_name" != "master" ]; then
      RUBY_THREAD_VM_STACK_SIZE=64000\
      bundle exec mutant\
        --include lib\
        --require reek\
        --use rspec\
        --since master\
        --jobs 4 'Reek*'
    else
      echo "!!! Not running mutant on master branch !!!"
    fi
  EOS
  system command
end
