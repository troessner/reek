require 'rubygems'
require 'rake/gempackagetask'
require 'yaml'
require 'reek'

GEMSPEC = "#{PROJECT_NAME}.gemspec"
HISTORY_FILE = 'History.txt'
README_FILE = 'README.md'

RELEASE_TIMESTAMP = "#{BUILD_DIR}/.last-release"

$gemspec = Gem::Specification.new do |s|
  s.name = PROJECT_NAME
  s.version = ::Reek::VERSION
  s.summary = 'Code smell detector for Ruby'
  s.description = <<-EOS
Reek is a tool that examines Ruby classes, modules and methods
and reports any code smells it finds.
EOS
  s.author = 'Kevin Rutherford'
  s.email = ['kevin@rutherford-software.com']
  s.homepage = 'http://wiki.github.com/kevinrutherford/reek'
  s.rubyforge_project = PROJECT_NAME
  s.add_dependency('ruby_parser', '~> 2.0')
  s.add_dependency('ruby2ruby', '~> 1.2')
  s.add_dependency('sexp_processor', '~> 3.0')
  s.files = File.read(GEM_MANIFEST).delete("\r").split(/\n/)
  s.executables = s.files.grep(/^bin/) { |f| File.basename(f) }
  s.bindir = 'bin'
  s.require_paths = ['lib']
  s.rdoc_options = ['--main', README_FILE]
  s.extra_rdoc_files = s.files.grep(/(txt|rdoc)$/)
  s.post_install_message = '
For more information on reek, see http://wiki.github.com/kevinrutherford/reek
'
end

class String
  def touch(text)
    File.open(self, 'w') { |ios| ios.puts text }
  end
end

file GEMSPEC => [GEM_MANIFEST, README_FILE, HISTORY_FILE, VERSION_FILE, __FILE__] do
  GEMSPEC.touch($gemspec.to_ruby)
end

namespace :build do
  Rake::GemPackageTask.new($gemspec) do |task|
    task.package_dir = PKG_DIR
    task.need_tar = true
    task.need_zip = false
  end

  task :package => [GEMSPEC]
end

task :release => ['test:release', 'build:package'] do
  puts <<-EOS
    1) git commit -a -m "Release #{Reek::VERSION}"
    2) git tag -a "v#{Reek::VERSION}" -m "Release #{Reek::VERSION}"
    3) git push
    4) git push --tags
    5) gem push "#{PKG_DIR}/#{PROJECT_NAME}-#{Reek::VERSION}.gem"
  EOS
  RELEASE_TIMESTAMP.touch(::Reek::VERSION)
end
