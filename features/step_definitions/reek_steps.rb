When /^I run reek (.*)$/ do |args|
  reek(args)
end

When /^I pass "([^\"]*)" to reek *(.*)$/ do |stdin, args|
  reek_with_pipe(stdin, args)
end

When /^I run rake (\w*) with:$/ do |name, task_def|
  rake(name, task_def)
end

Then /^it reports nothing$/ do
  assert_exact_output '', all_stdout
end

Then /^there is no output on stdout$/ do
  assert_exact_output '', all_stdout
end

Then /^stdout includes "(.*)"$/ do |text|
  assert_partial_output(text, all_stdout)
end

Then /^it succeeds$/ do
  assert_exit_status Reek::CLI::Application::STATUS_SUCCESS
end

Then /^the exit status indicates an error$/ do
  assert_exit_status Reek::CLI::Application::STATUS_ERROR
end

Then /^the exit status indicates smells$/ do
  assert_exit_status Reek::CLI::Application::STATUS_SMELLS
end

Then /^it reports:$/ do |report|
  assert_exact_output "#{report}\n", all_stdout
end

Then /^it reports this yaml:$/ do |expected_yaml|
  expected_warnings = YAML.load(expected_yaml.chomp)
  actual_warnings = YAML.load(all_stdout)
  expect(actual_warnings).to eq expected_warnings
end

Then /^it reports this JSON:$/ do |expected_json|
  expected_warnings = JSON.parse(expected_json.chomp)
  actual_warnings = JSON.parse(all_stdout)
  expect(actual_warnings).to eq expected_warnings
end

Then /^stderr reports:$/ do |report|
  assert_exact_output report, all_stderr
end

Then /^it reports no errors$/ do
  assert_exact_output '', all_stderr
end

Then /^it reports an error$/ do
  expect(all_stderr).to_not be_empty
end

Then /^it reports the error ['"](.*)['"]$/ do |string|
  assert_partial_output string, all_stderr
end

Then /^it reports a parsing error$/ do
  assert_partial_output 'Parser::SyntaxError', all_stderr
end

Then /^it should indicate the line numbers of those smells$/ do
  assert_matching_output /\[.*\]:/, all_stdout
end

Then /^it reports the current version$/ do
  assert_exact_output "reek #{Reek::Version::STRING}\n", all_stdout
end
