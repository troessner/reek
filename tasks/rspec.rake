require 'rake/clean'
require 'spec'
require 'spec/rake/spectask'

REPORT_DIR = 'spec/output/coverage'
SPECS = FileList['spec/**/*_spec.rb']

CLEAN.include(REPORT_DIR)

desc "runs the specs and reports coverage in #{REPORT_DIR}"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = SPECS
  t.rcov = true
  t.rcov_dir = REPORT_DIR
  t.rcov_opts = ['--exclude', 'spec,\.autotest']
end
