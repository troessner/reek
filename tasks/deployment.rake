require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rubyforge'
require 'yaml'
require 'reek'

begin
  gem 'rdoc'
rescue Gem::LoadError
end

GEMSPEC = "#{PROJECT_NAME}.$gemspec"
HISTORY_FILE = 'History.txt'

RELEASE_TIMESTAMP = "#{BUILD_DIR}/.last-release"
MANIFEST_CHECKED = "#{BUILD_DIR}/.manifest-checked"

$gemspec = Gem::Specification.new do |s|
  s.name = PROJECT_NAME
  s.version = ::Reek::VERSION
  s.summary = s.description = 'Code smell detector for Ruby'
  s.author = 'Kevin Rutherford'
  s.email = ['kevin@rutherford-software.com']
  s.homepage = 'http://wiki.github.com/kevinrutherford/reek'
  s.rubyforge_project = PROJECT_NAME
  s.add_dependency('ParseTree', '~> 3.0')
  s.add_dependency('sexp_processor', '~> 3.0')
  s.files = File.read(GEM_MANIFEST).delete("\r").split(/\n/)
  s.executables = s.files.grep(/^bin/) { |f| File.basename(f) }
  s.bindir = 'bin'
  s.require_paths = ['lib']
  s.rdoc_options = ['--main', 'README.txt']
  s.extra_rdoc_files = s.files.grep(/(txt|rdoc)$/)
  s.has_rdoc = true
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
  def rdoc_to_markdown
    self.gsub(/^(=+)/) { "#" * $1.size }
  end

  def touch(text = DateTime.now)
    File.touch(self, text)
  end
end

class Description

  def description
    "Reek detects smells in Ruby code. It can be used as a stand-alone
command, or as a Rake task, or as an expectation in Rspec examples."
  end

  def changes
    File.read("History.txt").split(/^(== .*)/)[2].strip
  end

  def subject
    "#{PROJECT_NAME} #{::Reek::VERSION} released"
  end
  def title
    "#{PROJECT_NAME} version #{::Reek::VERSION} has been released!"
  end
  def body
    "#{$gemspec.description}\n\n## Changes:\n\n#{changes}".rdoc_to_markdown
  end
  def urls
    result = <<EOR
* http://wiki.github.com/kevinrutherford/#{PROJECT_NAME}
* http://#{PROJECT_NAME}.rubyforge.org/rdoc/
EOR
    result
  end

  def news
    news = <<-EOM
#{title}

#{description}

## Changes in this release:

#{changes.rdoc_to_markdown}

## More information:

#{urls}
EOM
    return news
  end
end

class ::Rake::SshDirPublisher
  attr_reader :host, :remote_dir, :local_dir
end

file GEMSPEC => [GEM_MANIFEST, VERSION_FILE, __FILE__] do
  GEMSPEC.touch($gemspec.to_ruby)
end

namespace :release do

  desc 'Minor release on github only'
  task :minor => ['build:all', 'rubyforge:rdoc'] do
    puts <<-EOS
      1) git commit -a -m "Release #{Reek::VERSION}"
      2) git tag -a "v#{Reek::VERSION}" -m "Release #{Reek::VERSION}"
      3) git push
      4) git push --tags
    EOS
    RELEASE_TIMESTAMP.touch(::Reek::VERSION)
  end

  desc 'Major release (github+rubyforge) with news'
  task :major => ['release:minor', 'rubyforge:gem', 'rubyforge:news'] do
    
  end
end

def pkg_files
  require 'find'
  result = []
  Find.find '.' do |path|
    next unless File.file? path
    next if path =~ /\.git|build/
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

namespace :test do
  desc 'Install the gem locally'
  task :install => [:clean, 'build:all'] do
    gem = Dir["#{PKG_DIR}/*.gem"].first
    sh "sudo gem install --local #{gem}"
  end

  desc 'Show the gemspec'
  task :gemspec do
    puts $gemspec.to_ruby
  end

  desc 'Show the announcement email to be sent'
  task :email do
    puts Description.new.news
  end
end

def query(msg)
  print msg
  $stdin.gets
end

file MANIFEST_CHECKED => $package_files do
  display_manifest_diff
  if query('Is this manifest good to go? [yN]') =~ /y/i
    MANIFEST_CHECKED.touch
  else
    abort 'Check the manifest and try again'
  end
end
