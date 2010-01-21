require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'spec'
require 'spec/rake/spectask'

namespace 'test' do
  UNIT_TESTS = FileList['spec/reek/**/*_spec.rb']

  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = UNIT_TESTS
    t.spec_opts = ['--color']
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  desc 'Tests various release attributes of the gem'
  Spec::Rake::SpecTask.new('gem') do |t|
    t.spec_files = FileList['spec/gem/**/*_spec.rb']
    t.rcov = false
  end

  desc 'Tests code quality'
  Spec::Rake::SpecTask.new('quality') do |t|
    t.spec_files = FileList['quality/**/*_spec.rb']
    t.spec_opts = ['--color']
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  desc 'Runs all unit tests under RCov'
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = UNIT_TESTS
    t.rcov = true
    t.rcov_dir = 'build/coverage'
  end

  desc 'Checks all supported versions of Ruby'
  task :multiruby do
    sh "multiruby -S rake spec"
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format progress --color"
  end

  desc 'Runs all unit tests and acceptance tests'
  task 'all' => ['test:spec', 'test:features', 'test:multiruby']

  task 'release' => ['test:gem', 'test:all']
end

task 'clobber_rcov' => 'test:clobber_rcov'

desc 'Synonym for test:spec'
task 'spec' => 'test:spec'

desc 'Synonym for test:all'
task 'test' => 'test:all'
