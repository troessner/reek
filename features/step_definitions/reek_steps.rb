When /^I run reek (.*)$/ do |args|
  reek(args)
end

When /^I pass "([^\"]*)" to reek *(.*)$/ do |stdin, args|
  reek_with_pipe(stdin, args)
end

When /^I run rake (\w*) with:$/ do |name, task_def|
  rake(name, task_def)
end

Then /^stdout equals "([^\"]*)"$/ do |report|
  @last_stdout.should == report
end

Then /^stdout includes \/([^\"]*)\/$/ do |report|
  @last_stdout.should match(report)
end

Then /^it succeeds$/ do
  @last_exit_status.should == Reek::Cli::Application::STATUS_SUCCESS
end

Then /^the exit status indicates an error$/ do
  @last_exit_status.should == Reek::Cli::Application::STATUS_ERROR
end

Then /^the exit status indicates smells$/ do
  @last_exit_status.should == Reek::Cli::Application::STATUS_SMELLS
end

Then /^it reports:$/ do |report|
  @last_stdout.chomp.should == report.chomp
end

Then /^it reports this yaml:$/ do |expected_yaml|
  expected_warnings = YAML.load(expected_yaml.chomp)
  actual_warnings = YAML.load(@last_stdout)
  actual_warnings.should == expected_warnings
end

Then /^stderr reports:$/ do |report|
  @last_stderr.should == report
end

Then /^it reports no errors$/ do
  @last_stderr.chomp.should eq ""
end

Then /^it reports an error$/ do
  @last_stderr.chomp.should_not be_empty
end

Then /^it reports the error ['"](.*)['"]$/ do |string|
  @last_stderr.chomp.should == string
end

Then /^it reports a parsing error$/ do
  @last_stderr.chomp.should match(/Racc::ParseError/)
end

Then /^it should indicate the line numbers of those smells$/ do
  @last_stdout.chomp.should match(/\[.*\]:/)
end

Then /^it reports the current version$/ do
  @last_stdout.should == "reek #{Reek::VERSION}\n"
end
