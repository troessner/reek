require 'bundler/gem_tasks'
require 'rake/clean'

Dir['tasks/**/*.rake'].each { |t| load t }

defaults = ['test:spec',
            # Should run before test:features so we have the the most up-to-date default configuration
            'configuration:update_default_configuration',
            'test:features',
            :rubocop,
            'test:quality']

task :local_test_run do
  defaults.each do |name|
    wrap_rake_task_output name
  end
end

task ci: (defaults + [:ataru])
task default: :local_test_run

def wrap_rake_task_output(name)
  puts "\n=== Running #{name}...\n"
  Rake::Task[name].invoke
  puts "\n=== Running #{name} -> Done\n"
end
