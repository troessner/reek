require 'rake/clean'
require 'spec'
require 'spec/rake/spectask'

REPORT_DIR = 'spec/output/coverage'
UNITS = FileList['spec/reek/**/*_spec.rb']
INTEGS = FileList['spec/integration/**/*_spec.rb']

CLEAN.include(REPORT_DIR)

desc "runs the specs and reports coverage in #{REPORT_DIR}"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = UNITS
  t.rcov = true
  t.rcov_dir = REPORT_DIR
  t.rcov_opts = ['--exclude', 'spec,\.autotest']
end

desc "runs the unit and intergration tests"
Spec::Rake::SpecTask.new(:cruise) do |t|
  t.spec_files = UNITS + INTEGS
  t.rcov = false
end
