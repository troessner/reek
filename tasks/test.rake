require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec'
require 'rspec/core/rake_task'

namespace 'test' do
  UNIT_TESTS = FileList['spec/reek/**/*_spec.rb']

  RSpec::Core::RakeTask.new('spec') do |t|
    t.pattern = UNIT_TESTS
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  desc 'Tests various release attributes of the gem'
  RSpec::Core::RakeTask.new('gem') do |t|
    t.pattern = FileList['spec/gem/**/*_spec.rb']
    t.rcov = false
  end

  desc 'Tests code quality'
  RSpec::Core::RakeTask.new('quality') do |t|
    t.pattern = FileList['quality/**/*_spec.rb']
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  desc 'Runs all unit tests under RCov'
  RSpec::Core::RakeTask.new('rcov') do |t|
    t.pattern = UNIT_TESTS
    t.rcov = true
    t.rcov_opts = '-o build/coverage'
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format progress --color"
  end

  desc 'Runs all unit tests and acceptance tests'
  task 'all' => ['test:spec', 'test:features']
end

task 'clobber_rcov' => 'test:clobber_rcov'

desc 'Synonym for test:spec'
task 'spec' => 'test:spec'

desc 'Synonym for test:all'
task 'test' => 'test:all'
