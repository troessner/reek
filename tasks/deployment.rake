require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rubyforge'
require 'yaml'
require 'reek'

begin
  gem 'rdoc'
rescue Gem::LoadError
end

gemspec = Gem::Specification.new do |s|
  s.name = PROJECT_NAME
  s.version = ::Reek::VERSION
  s.summary = s.description = 'Code smell detector for Ruby'
  s.author = 'Kevin Rutherford'
  s.email = ['kevin@rutherford-software.com']
  s.homepage = 'http://wiki.github.com/kevinrutherford/reek'
  s.rubyforge_project = PROJECT_NAME
  s.add_dependency('ParseTree', '~> 3.0')
  s.add_dependency('sexp_processor', '~> 3.0')
  s.files = File.read("Manifest.txt").delete("\r").split(/\n/)
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
  body    = "#{gemspec.description}\n\nChanges:\n\n#{changes}".rdoc_to_markdown
  urls    = <<EOU
* http://wiki.github.com/kevinrutherford/reek
* http://reek.rubyforge.org/rdoc/
* http://github.com/kevinrutherford/reek
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

GEMSPEC = "#{PROJECT_NAME}.gemspec"

file GEMSPEC => ['Manifest.txt', 'lib/reek.rb', __FILE__] do
  puts "Generating #{GEMSPEC}"
  File.open(GEMSPEC, 'w') do |file|
    file.puts gemspec.to_ruby
  end
  puts "1) git commit -a -m \"Release #{Reek::VERSION}\""
  puts "2) git tag -a \"v#{Reek::VERSION}\" -m \"Release #{Reek::VERSION}\""
  puts "3) git push"
  puts "4) git push --tags"
end

task :release do
  puts <<-EOS.gsub(/^  /,'')
  1) git tag REL-#{::Reek::VERSION}
  2) rake post_news
  EOS
end

desc 'Publish RDoc to RubyForge'
task :publish_docs => [:clean, :docs] do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{PROJECT_NAME}/rdoc"
  local_dir = 'doc'
  sh %{rsync -av --delete --ignore-errors #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Install the package as a gem'
task :install_gem => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "sudo gem install --local #{gem}"
end

desc 'Verify the manifest'
task :check_manifest => [:clean] do
  f = "Manifest.tmp"
  require 'find'
  files = []
  Find.find '.' do |path|
    next unless File.file? path
    next if path =~ /\.git/
    files << path[2..-1]
  end
  files = files.sort.join "\n"
  File.open(f, 'w') do |fp| fp.puts files end
  system "diff -du Manifest.txt #{f}"
  rm f
end

desc 'Show information about the gem'
task :show_gemspec do
  puts gemspec.to_ruby
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = false
end

Rake::RDocTask.new(:docs) do |rd|
  rd.main = 'README.txt'
  rd.rdoc_dir = 'doc'
  files = gemspec.files.grep(/^(lib|bin|ext)|txt|rdoc$/)
  files -= ['Manifest.txt']
  rd.rdoc_files.push(*files)
  title = "#{PROJECT_NAME}-#{::Reek::VERSION} Documentation"
  rd.options << "-t #{title}"
end

desc 'Package and upload the release to rubyforge'
task :release => [:clean, :package] do |t|
  pkg = "pkg/#{PROJECT_NAME}-#{::Reek::VERSION}"
  rf = RubyForge.new.configure
  puts "Logging in"
  rf.login
  c = rf.userconfig
  c["release_notes"] = @description if @description
  c["release_changes"] = changes if changes
  c["preformatted"] = true
  files = ["#{pkg}.tgz", "#{pkg}.gem"].compact
  puts "Releasing #{PROJECT_NAME} v. #{::Reek::VERSION}"
  rf.add_release(PROJECT_NAME, PROJECT_NAME, ::Reek::VERSION, *files)
end
