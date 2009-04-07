require 'spec'
require 'spec/rake/spectask'

namespace 'rspec' do
  FAST = FileList['spec/reek/**/*_spec.rb']
  SLOW = FileList['spec/slow/**/*_spec.rb']

  Spec::Rake::SpecTask.new('fast') do |t|
    t.spec_files = FAST
    t.ruby_opts = ['-Ilib']
    t.rcov = false
  end

  Spec::Rake::SpecTask.new('all') do |t|
    t.spec_files = FAST + SLOW
    t.rcov = false
  end
end

desc 'runs the unit tests'
task 'spec' => 'rspec:fast'
