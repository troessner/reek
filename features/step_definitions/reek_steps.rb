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
  expect(@last_stdout).to eq report
end

Then /^stdout includes "(.*)"$/ do |text|
  expect(@last_stdout).to include text
end

Then /^it succeeds$/ do
  expect(@last_exit_status).to eq Reek::Cli::Application::STATUS_SUCCESS
end

Then /^the exit status indicates an error$/ do
  expect(@last_exit_status).to eq Reek::Cli::Application::STATUS_ERROR
end

Then /^the exit status indicates smells$/ do
  expect(@last_exit_status).to eq Reek::Cli::Application::STATUS_SMELLS
end

Then /^it reports:$/ do |report|
  expect(@last_stdout.chomp).to eq report.chomp
end

Then /^it reports this yaml:$/ do |expected_yaml|
  expected_warnings = YAML.load(expected_yaml.chomp)
  actual_warnings = YAML.load(@last_stdout)
  expect(actual_warnings).to eq expected_warnings
end

Then /^stderr reports:$/ do |report|
  expect(@last_stderr).to eq report
end

Then /^it reports no errors$/ do
  expect(@last_stderr.chomp).to eq ''
end

Then /^it reports an error$/ do
  expect(@last_stderr.chomp).to_not be_empty
end

Then /^it reports the error ['"](.*)['"]$/ do |string|
  expect(@last_stderr.chomp).to eq string
end

Then /^it reports a parsing error$/ do
  expect(@last_stderr.chomp).to match(/Parser::SyntaxError/)
end

Then /^it should indicate the line numbers of those smells$/ do
  expect(@last_stdout.chomp).to match(/\[.*\]:/)
end

Then /^it reports the current version$/ do
  expect(@last_stdout).to eq "reek #{Reek::VERSION}\n"
end

Given(/^"(.*?)" exists in the working directory$/) do |path|
  FileUtils.cp path, Pathname.pwd
end

Given(/^"(.*?)" exists in the parent directory of the working directory$/) do |path|
  FileUtils.cp path, Pathname.pwd.parent
end

Given(/^"(.*?)" exists in the HOME directory$/) do |path|
  FileUtils.cp path, Pathname.new(Dir.home)
end
