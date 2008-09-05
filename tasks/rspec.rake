require 'rake/clean'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  require 'spec'
end
begin
  require 'spec/rake/spectask'
  require 'spec/rake/verify_rcov'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end

REPORT_DIR = 'spec/output/coverage'
CLEAN.include(REPORT_DIR)

desc 'runs the specs in colour'
Spec::Rake::SpecTask.new(:spec_colour) do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:spec_rcov) do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_dir = REPORT_DIR
  t.rcov_opts = ['--exclude', 'spec,\.autotest']
end

"runs the specs and reports coverage in #{REPORT_DIR}"
RCov::VerifyTask.new(:spec => :spec_rcov) do |t|
  t.index_html = "#{REPORT_DIR}/index.html"
  t.threshold = 100
end
