require_relative '../../samples/paths'

Given(/^the smelly file '(.+)'$/) do |filename|
  write_file(filename, SAMPLES_PATH.join(filename).read)
end

Given(/^the clean file 'clean.rb'$/) do
  write_file('clean.rb', CLEAN_FILE.read)
end

Given(/^a directory called 'clean' containing two clean files$/) do
  contents = CLEAN_FILE.read

  write_file('clean/clean_one.rb', contents)
  write_file('clean/clean_two.rb', contents)
end

Given(/^a directory called 'mixed_files' containing some clean and smelly files$/) do
  write_file('mixed_files/clean.rb', CLEAN_FILE.read)
  write_file('mixed_files/dirty.rb', SMELLY_FILE.read)
end

Given(/^a directory called 'smelly' containing two smelly files$/) do
  contents = SMELLY_FILE.read

  write_file('smelly/dirty_one.rb', contents)
  write_file('smelly/dirty_two.rb', contents)
end

Given(/^the smelly file '(.+)' in a subdirectory$/) do |filename|
  contents = SAMPLES_PATH.join(filename).read

  write_file("subdir/#{filename}", contents)
end

Given(/^a configuration file '(.+)'$/) do |filename|
  write_file(filename, CONFIG_PATH.join(filename).read)
end

When(/^I run "reek (.*?)" in a subdirectory$/) do |args|
  cd 'subdir'

  reek(args)
end

Given(/^a configuration file '(.+)' in a subdirectory$/) do |filename|
  contents = CONFIG_PATH.join(filename).read

  write_file("subdir/#{filename}", contents)
end

Then(/^it does not report private or protected methods$/) do
  # Pseudo step for feature clarity.
end
