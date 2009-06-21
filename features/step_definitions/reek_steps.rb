When /^I run reek (.*)$/ do |args|
  @last_output = `ruby -Ilib bin/reek #{args}`
  @last_exit_status = $?.exitstatus
end

Then /^it fails with exit status (\d+)$/ do |status|
  @last_exit_status.should == status.to_i
end

Then /^it reports:$/ do |report|
  @last_output.should == report
end
