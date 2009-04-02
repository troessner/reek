require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rbconfig'
require 'rubyforge'
require 'yaml'
require 'reek'

begin
  gem 'rdoc'
rescue Gem::LoadError
end

class Hoe
  attr_accessor :changes
  attr_accessor :clean_globs
  attr_accessor :description
  attr_accessor :description_sections
  attr_accessor :extra_deps
  attr_accessor :extra_dev_deps
  attr_accessor :spec
  attr_accessor :summary
  attr_accessor :url
  attr_accessor :version

  def normalize_deps deps
    Array(deps).map { |o| String === o ? [o] : o }
  end

  def missing name
    warn "** #{name} is missing or in the wrong format for auto-intuiting."
    warn "   run `sow blah` and look at its text files"
  end

  def initialize(name, version) # :nodoc:
    self.version = version

    # Defaults
    self.clean_globs = %w(diff diff.txt email.txt ri deps .source_index
                          *.gem *~ **/*~ *.rbc **/*.rbc)
    self.description_sections = %w(description)
    self.extra_deps = []
    self.extra_dev_deps = []

    yield self if block_given?

    # Intuit values:

    readme = File.read('README.txt').split(/^(=+ .*)$/)[1..-1] rescue ''
    unless readme.empty? then
      sections = readme.map { |s|
        s =~ /^=/ ? s.strip.downcase.chomp(':').split.last : s.strip
      }
      sections = Hash[*sections]
      desc = sections.values_at(*description_sections).join("\n\n")
      summ = desc.split(/\.\s+/).first(1).join(". ")
      self.description ||= desc
      self.summary ||= summ
      self.url ||= readme[1].gsub(/^\* /, '').split(/\n/).grep(/\S+/)
    else
      missing 'README.txt'
    end
    self.changes ||= begin
                       h = File.read("History.txt")
                       h.split(/^(===.*)/)[1..2].join.strip
                     rescue
                       missing 'History.txt'
                       ''
                     end
    self.extra_deps     = normalize_deps extra_deps
    self.extra_dev_deps = normalize_deps extra_dev_deps
    define_tasks
  end

  def define_tasks

    ############################################################
    # Packaging and Installing

    self.spec = Gem::Specification.new do |s|
      s.name = PROJECT_NAME
      s.version = version
      s.summary = s.description = 'Code smell detector for Ruby'
      s.author = 'Kevin Rutherford'
      s.email = ['kevin@rutherford-software.com']
      s.homepage = 'http://wiki.github.com/kevinrutherford/reek'
      s.rubyforge_project = PROJECT_NAME
      extra_deps.each do |dep|
        s.add_dependency(*dep)
      end
      extra_dev_deps.each do |dep|
        s.add_development_dependency(*dep)
      end
      s.files = File.read("Manifest.txt").delete("\r").split(/\n/)
      s.executables = s.files.grep(/^bin/) { |f| File.basename(f) }
      s.bindir = "bin"
      s.require_paths = ['lib']
      s.rdoc_options = ['--main', 'README.txt']
      s.extra_rdoc_files = s.files.grep(/(txt|rdoc)$/)
      s.has_rdoc = true
      s.post_install_message = '
For more information on reek, see http://wiki.github.com/kevinrutherford/reek
'
    end

    desc 'Show information about the gem.'
    task :show_gemspec do
      puts spec.to_ruby
    end

    Rake::GemPackageTask.new spec do |pkg|
      pkg.need_tar = true
      pkg.need_zip = false
    end

    desc 'Install the package as a gem.'
    task :install_gem => [:clean, :package] do
      gem = Dir['pkg/*.gem'].first
      sh "sudo gem install --local #{gem}"
    end

    desc 'Package and upload the release to rubyforge.'
    task :release => [:clean, :package] do |t|
      v = ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
      abort "Versions don't match #{v} vs #{version}" if v != version
      pkg = "pkg/#{name}-#{version}"
      rf = RubyForge.new.configure
      puts "Logging in"
      rf.login
      c = rf.userconfig
      c["release_notes"] = description if description
      c["release_changes"] = changes if changes
      c["preformatted"] = true
      files = ["#{pkg}.tgz", "#{pkg}.gem"].compact
      puts "Releasing #{name} v. #{version}"
      rf.add_release PROJECT_NAME, name, version, *files
    end

    Rake::RDocTask.new(:docs) do |rd|
      rd.main = 'README.txt'
      rd.rdoc_dir = 'doc'
      files = spec.files.grep(/^(lib|bin|ext)|txt|rdoc$/)
      files -= ['Manifest.txt']
      rd.rdoc_files.push(*files)
      title = "#{PROJECT_NAME}-#{version} Documentation"
      rd.options << "-t #{title}"
    end

    desc 'Clean up all the extras.'
    task :clean => [ :clobber_docs, :clobber_package ] do
      clean_globs.each do |pattern|
        files = Dir[pattern]
        rm_rf files, :verbose => true unless files.empty?
      end
    end

    desc 'Generate email announcement file.'
    task :email do
      require 'rubyforge'
      subject, title, body, urls = announcement
      File.open("email.txt", "w") do |mail|
        mail.puts "Subject: [ANN] #{subject}"
        mail.puts
        mail.puts title
        mail.puts
        mail.puts urls
        mail.puts
        mail.puts body
        mail.puts
        mail.puts urls
      end
      puts "Created email.txt"
    end

    desc 'Post announcement to rubyforge.'
    task :post_news do
      require 'rubyforge'
      subject, title, body, urls = announcement
      rf = RubyForge.new.configure
      rf.login
      rf.post_news(PROJECT_NAME, subject, "#{title}\n\n#{body}")
      puts "Posted to rubyforge"
    end

    desc 'Verify the manifest.'
    task :check_manifest => :clean do
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
  end

  def announcement
    changes = self.changes.rdoc_to_markdown
    subject = "#{name} #{version} Released"
    title   = "#{name} version #{version} has been released!"
    body    = "#{description}\n\nChanges:\n\n#{changes}".rdoc_to_markdown
    urls    = Array(url).map { |s| "* <#{s.strip.rdoc_to_markdown}>" }.join("\n")
    return subject, title, body, urls
  end

  def paragraphs_of(path, *paragraphs)
    File.read(path).delete("\r").split(/\n\n+/).values_at(*paragraphs)
  end
end

class ::Rake::SshDirPublisher
  attr_reader :host, :remote_dir, :local_dir
end

class String
  def rdoc_to_markdown
    self.gsub(/^mailto:/, '').gsub(/^(=+)/) { "#" * $1.size }
  end
end

$hoe = Hoe.new(PROJECT_NAME, ::Reek::VERSION) do |p|
  p.changes = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.extra_deps = [
    ['ParseTree', '~> 3.0'],
    ['sexp_processor', '~> 3.0']
  ]
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  p.summary = 'Code smell detector for Ruby'
end

GEMSPEC = "#{PROJECT_NAME}.gemspec"

file GEMSPEC => ['Manifest.txt', 'lib/reek.rb', __FILE__] do
  puts "Generating #{GEMSPEC}"
  File.open(GEMSPEC, 'w') do |file|
    file.puts $hoe.spec.to_ruby
  end
  puts "1) git commit -a -m \"Release #{Reek::VERSION}\""
  puts "2) git tag -a \"v#{Reek::VERSION}\" -m \"Release #{Reek::VERSION}\""
  puts "3) git push"
  puts "4) git push --tags"
end

task :release do
  puts <<-EOS.gsub(/^  /,'')
  Remember to create tag your release; eg for Git:
    git tag REL-#{$hoe.version}
  
  Announce your release on RubyForge News:
    rake post_news
  EOS
end

desc 'Publish RDoc to RubyForge.'
task :publish_docs => [:clean, :docs] do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{PROJECT_NAME}/rdoc"
  local_dir = 'doc'
  sh %{rsync -av --delete --ignore-errors #{local_dir}/ #{host}:#{remote_dir}}
end
