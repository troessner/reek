require 'rubygems'

namespace :build do
  Rake::GemPackageTask.new($gemspec) do |task|
    task.package_dir = PKG_DIR
    task.need_tar = true
    task.need_zip = false
  end

  task :gem => [MANIFEST_CHECKED, 'rspec:all']

  Rake::RDocTask.new do |rd|
    rd.main = 'README.txt'
    rd.rdoc_dir = RDOC_DIR
    files = $gemspec.files.grep(/^(lib|bin|ext)|txt|rdoc$/)
    files -= [GEM_MANIFEST]
    rd.rdoc_files.push(*files)
    title = "#{PROJECT_NAME}-#{::Reek::VERSION} Documentation"
    rd.options << "-t #{title}"
  end

  task :rdoc => [RDOC_DIR, MANIFEST_CHECKED]
  task :all => ['build:package', 'build:rdoc']
end
