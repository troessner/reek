require 'rubygems'
require 'rake/gempackagetask'
require 'yaml'
require 'reek'

GEMSPEC = "#{PROJECT_NAME}.gemspec"
HISTORY_FILE = 'History.txt'
README_FILE = 'README.rdoc'

RELEASE_TIMESTAMP = "#{BUILD_DIR}/.last-release"
MANIFEST_CHECKED = "#{BUILD_DIR}/.manifest-checked"

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

class File
  def self.touch(path, text)
    File.open(path, 'w') { |ios| ios.puts text }
  end
end

class String
  def touch(text = DateTime.now)
    File.touch(self, text)
  end
end

class ::Rake::SshDirPublisher
  attr_reader :host, :remote_dir, :local_dir
end

file GEMSPEC => [GEM_MANIFEST, README_FILE, HISTORY_FILE, VERSION_FILE, __FILE__] do
  GEMSPEC.touch($gemspec.to_ruby)
end

file HISTORY_FILE => [RELEASE_TIMESTAMP] do
  abort "Update #{HISTORY_FILE} before attempting to release"
end

file VERSION_FILE => [RELEASE_TIMESTAMP] do
  abort "Update #{VERSION_FILE} before attempting to release"
end

task :release => ['build:all'] do
  puts <<-EOS
    1) git commit -a -m "Release #{Reek::VERSION}"
    2) git tag -a "v#{Reek::VERSION}" -m "Release #{Reek::VERSION}"
    3) git push
    4) git push --tags
    5) gem push "#{PKG_DIR}/#{PROJECT_NAME}-#{Reek::VERSION}.gem"
  EOS
  RELEASE_TIMESTAMP.touch(::Reek::VERSION)
end

def pkg_files
  require 'find'
  result = []
  Find.find '.' do |path|
    next unless File.file? path
    next if path =~ /\.git|build|tmp|quality|xp.reek|Manifest.txt|develop.rake|deployment.rake/
    result << path[2..-1]
  end
  result
end

$package_files = pkg_files

def display_manifest_diff
  f = "Manifest.tmp"
  f.touch(pkg_files.sort.join("\n"))
  system "diff -du #{GEM_MANIFEST} #{f}"
  rm f
end

namespace :check do
  desc 'Install the gem locally'
  task :install => [:clean, 'build:all'] do
    gem = Dir["#{PKG_DIR}/*.gem"].first
    sh "sudo gem install --local #{gem}"
  end

  desc 'Show the gemspec'
  task :gemspec do
    puts $gemspec.to_ruby
  end

  task :manifest do
    display_manifest_diff
  end
end

def query(msg)
  print msg
  $stdin.gets
end

file MANIFEST_CHECKED => $package_files do
  display_manifest_diff
  if query('Is this manifest good to go? [Ny] ') =~ /y/i
    MANIFEST_CHECKED.touch
  else
    abort 'Check the manifest and try again'
  end
end

namespace :build do
  Rake::GemPackageTask.new($gemspec) do |task|
    task.package_dir = PKG_DIR
    task.need_tar = true
    task.need_zip = false
  end

  task :gem => [MANIFEST_CHECKED, 'test:all']

  task :all => ['build:package']
end
