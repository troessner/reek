require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'

namespace 'test' do
  UNIT_TESTS = FileList['spec/sexp_dresser/**/*_spec.rb']

 RSpec::Core::RakeTask.new('spec') do |t|
    t.pattern = UNIT_TESTS
    t.rspec_opts = ['--color']
    t.ruby_opts = ['-Ilib']
    t.fail_on_error = true
    t.verbose = false
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
    t.rspec_opts = ['--color']
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end
end

desc 'Synonym for test:spec'
task 'test' => 'test:spec'
