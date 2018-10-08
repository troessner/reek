require_relative '../../samples/paths'

Given(/^the smelly file '(.+)'$/) do |filename|
  write_file(filename, SAMPLES_DIR.join('smelly_source').join(filename).read)
end

Given(/^the smelly file "(.+)" in the directory "(.+)"$/) do |filename, directory|
  FileUtils.mkdir_p directory
  write_file Pathname(directory).join(filename).to_s,
             SAMPLES_DIR.join('smelly_source').join(filename).read
end

Given(/^the clean file "(.*)"$/) do |filename|
  write_file(filename, CLEAN_FILE.read)
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
  contents = SAMPLES_DIR.join('smelly_source').join(filename).read

  write_file("subdir/#{filename}", contents)
end

Given(/^a configuration file '(.+)'$/) do |filename|
  write_file(filename, CONFIGURATION_DIR.join(filename).read)
end

Given(/^our default configuration file$/) do
  default_configuration = File.read SAMPLES_DIR.join('..').join('docs').join('defaults.reek.yml')
  write_file('defaults.reek', default_configuration)
end

When(/^I run "reek (.*?)" in a subdirectory$/) do |args|
  cd 'subdir'

  reek(args)
end

Then(/^it does not report private or protected methods$/) do
  # Pseudo step for feature clarity.
end

Given('with a configuration file that is further up in the directory tree') do
  # Pseudo step for feature clarity. We have an empty .reek.yml in our root directory already.
end
