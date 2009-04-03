require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rubyforge'
require 'yaml'
require 'reek'

begin
  gem 'rdoc'
rescue Gem::LoadError
end

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

class String
  def rdoc_to_markdown
    self.gsub(/^(=+)/) { "#" * $1.size }
  end
end

def changes
  File.read("History.txt").split(/^(== .*)/)[2].strip
end

def announcement
  subject = "#{PROJECT_NAME} #{::Reek::VERSION} Released"
  title   = "#{PROJECT_NAME} version #{::Reek::VERSION} has been released!"
  body    = "#{$gemspec.description}\n\nChanges:\n\n#{changes}".rdoc_to_markdown
  urls    = <<EOU
* http://wiki.github.com/kevinrutherford/reek
* http://reek.rubyforge.org/rdoc/
EOU
  return subject, title, body, urls
end

desc 'Post announcement to rubyforge'
task :post_news do
  subject, title, body, urls = announcement
  rf = RubyForge.new.configure
  rf.login
  rf.post_news(PROJECT_NAME, subject, "#{title}\n\n#{body}")
  puts "Posted to rubyforge"
end

desc 'Generate email announcement'
task :email do
  subject, title, body, urls = announcement
  email = <<EOM
Subject: [ANN] #{subject}

#{title}

#{urls}

#{body}

#{urls}
EOM
  puts email
end

class ::Rake::SshDirPublisher
  attr_reader :host, :remote_dir, :local_dir
end

GEMSPEC = "#{PROJECT_NAME}.$gemspec"

file GEMSPEC => [GEM_MANIFEST, 'lib/reek.rb', __FILE__] do
  puts "Generating #{GEMSPEC}"
  File.open(GEMSPEC, 'w') do |file|
    file.puts $gemspec.to_ruby
  end
end

namespace :build do
  Rake::GemPackageTask.new($gemspec) do |task|
    task.package_dir = PKG_DIR
    task.need_tar = true
    task.need_zip = false
  end

  task :gem => ['rspec:all']

  Rake::RDocTask.new do |rd|
    rd.main = 'README.txt'
    rd.rdoc_dir = RDOC_DIR
    files = $gemspec.files.grep(/^(lib|bin|ext)|txt|rdoc$/)
    files -= [GEM_MANIFEST]
    rd.rdoc_files.push(*files)
    title = "#{PROJECT_NAME}-#{::Reek::VERSION} Documentation"
    rd.options << "-t #{title}"
  end

  task :rdoc => [RDOC_DIR]
  task :all => ['build:package', 'build:rdoc']
end

namespace :release do
  task :version_bumped do
    #abort 'Version not bumped!'
  end

  desc 'Minor release on github only'
  task :minor => ['version_bumped', 'build:package', 'rubyforge:rdoc'] do
    puts <<-EOS
      1) git commit -a -m "Release #{Reek::VERSION}"
      2) git tag -a "v#{Reek::VERSION}" -m "Release #{Reek::VERSION}"
      3) git push
      4) git push --tags
    EOS
  end

  desc 'Major release (github+rubyforge) with news'
  task :major do
    
  end
end

namespace :test do
  desc 'Install the gem locally'
  task :install => [:clean, 'build:all'] do
    gem = Dir["#{PKG_DIR}/*.gem"].first
    sh "sudo gem install --local #{gem}"
  end

  desc 'Verify the manifest'
  task :manifest => [:clobber] do
    f = "Manifest.tmp"
    require 'find'
    files = []
    Find.find '.' do |path|
      next unless File.file? path
      next if path =~ /\.git|build/
      files << path[2..-1]
    end
    files = files.sort.join "\n"
    File.open(f, 'w') do |fp| fp.puts files end
    system "diff -du #{GEM_MANIFEST} #{f}"
    rm f
  end

  desc 'Show the gemspec'
  task :gemspec do
    puts $gemspec.to_ruby
  end
end
