require 'cucumber/rake/task'
require 'rspec/core/rake_task'

namespace 'test' do
  RSpec::Core::RakeTask.new('spec') do |t|
    # TODO: Add spec/performance once its stable.
    t.pattern = 'spec/reek/**/*_spec.rb'
    t.ruby_opts = ['-rbundler/setup -rsimplecov -Ilib -w']
  end

  desc 'Tests code quality'
  RSpec::Core::RakeTask.new('quality') do |t|
    t.pattern = 'spec/quality/**/*_spec.rb'
    t.ruby_opts = ['-rbundler/setup -Ilib']
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = 'features --format progress --color'
  end

  desc 'Runs all unit tests and acceptance tests'
  task 'all' => ['test:spec', 'test:features']
end

desc 'Synonym for test:spec'
task 'spec' => 'test:spec'

desc 'Synonym for test:all'
task 'test' => 'test:all'
