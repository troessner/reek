When /^I run reek (.*)$/ do |args|
  run args
end

Then /^it fails with exit status (\d+)$/ do |status|
  @last_exit_status.should == status.to_i
end

Then /^it reports:$/ do |report|
  @last_stdout.should == report
end

Then /^it displays the error message:$/ do |string|
  @last_stderr.should == string
end