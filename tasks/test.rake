require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'spec'
require 'spec/rake/spectask'

namespace 'test' do
  FAST = FileList['spec/reek/**/*_spec.rb']
  SLOW = FileList['spec/slow/**/*_spec.rb']

  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FAST
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  Spec::Rake::SpecTask.new('slow') do |t|
    t.spec_files = SLOW
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  desc 'Runs all unit tests under RCov'
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FAST + SLOW
    t.rcov = true
    t.rcov_dir = 'build/coverage'
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format progress --no-color"
  end

  desc 'Runs all unit tests and acceptance tests'
  task 'all' => ['test:spec', 'test:slow', 'test:features']
end

desc 'synonym for test:spec'
task 'spec' => 'test:spec'

desc 'synonym for test:all'
task 'test' => 'test:all'
