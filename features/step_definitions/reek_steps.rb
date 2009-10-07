When /^I run reek (.*)$/ do |args|
  reek(args)
end

When /^I pass "([^\"]*)" to reek *(.*)$/ do |stdin, args|
  reek_with_pipe(stdin, args)
end

When /^I run rake reek$/ do
  rake
end

Then /^stdout equals "([^\"]*)"$/ do |report|
  @last_stdout.should == report
end

Then /^it succeeds$/ do
  @last_exit_status.should == Reek::EXIT_STATUS[:success]
end

Then /^the exit status indicates an error$/ do
  @last_exit_status.should == Reek::EXIT_STATUS[:error]
end

Then /^the exit status indicates smells$/ do
  @last_exit_status.should == Reek::EXIT_STATUS[:smells]
end

Then /^it reports:$/ do |report|
  @last_stdout.should == report
end

Then /^it reports the error ['"](.*)['"]$/ do |string|
  @last_stderr.chomp.should == string
end

Then /^it reports the current version$/ do
  @last_stdout.chomp.should == "reek #{Reek::VERSION}"
end
