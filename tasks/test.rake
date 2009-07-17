require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'spec'
require 'spec/rake/spectask'

namespace 'test' do
  UNIT_TESTS = FileList['spec/reek/**/*_spec.rb']
  QUALITY_TESTS = FileList['spec/quality/**/*_spec.rb']

  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = UNIT_TESTS
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  Spec::Rake::SpecTask.new('quality') do |t|
    t.spec_files = QUALITY_TESTS
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  desc 'Runs all unit tests under RCov'
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = UNIT_TESTS + QUALITY_TESTS
    t.rcov = true
    t.rcov_dir = 'build/coverage'
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format progress --no-color"
  end

  desc 'Runs all unit tests and acceptance tests'
  task 'all' => ['test:spec', 'test:features', 'test:quality']
end

task 'clobber_rcov' => 'test:clobber_rcov'

desc 'synonym for test:spec'
task 'spec' => 'test:spec'

desc 'synonym for test:all'
task 'test' => 'test:all'
