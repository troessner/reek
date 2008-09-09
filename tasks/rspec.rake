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

desc "runs the specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

desc "runs the specs and reports coverage in #{REPORT_DIR}"
Spec::Rake::SpecTask.new(:spec_rcov) do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_dir = REPORT_DIR
  t.rcov_opts = ['--exclude', 'spec,\.autotest']
end

desc "runs the specs and checks for 100% coverage"
RCov::VerifyTask.new(:rcov => :spec_rcov) do |t|
  t.index_html = "#{REPORT_DIR}/index.html"
  t.threshold = 100
end
