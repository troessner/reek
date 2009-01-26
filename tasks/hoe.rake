# -*- ruby -*-

require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rbconfig'
require 'rubyforge'
require 'yaml'

begin
  gem 'rdoc'
rescue Gem::LoadError
end

class Hoe
  VERSION = '1.8.2'

  ruby_prefix = Config::CONFIG['prefix']
  sitelibdir = Config::CONFIG['sitelibdir']

  ##
  # Used to specify a custom install location (for rake install).

  PREFIX = ENV['PREFIX'] || ruby_prefix

  ##
  # Used to add extra flags to RUBY_FLAGS.

  RUBY_DEBUG = ENV['RUBY_DEBUG']

  default_ruby_flags = "-w -I#{%w(lib ext bin test).join(File::PATH_SEPARATOR)}" +
    (RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')

  ##
  # Used to specify flags to ruby [has smart default].

  RUBY_FLAGS = ENV['RUBY_FLAGS'] || default_ruby_flags

  ##
  # Used to add flags to test_unit (e.g., -n test_borked).

  FILTER = ENV['FILTER'] # for tests (eg FILTER="-n test_blah")

  # :stopdoc:

  RUBYLIB = if PREFIX == ruby_prefix then
              sitelibdir
            else
              File.join(PREFIX, sitelibdir[ruby_prefix.size..-1])
            end

  DLEXT = Config::CONFIG['DLEXT']

  WINDOZE = /mswin|mingw/ =~ RUBY_PLATFORM unless defined? WINDOZE

  attr_accessor :author
  attr_accessor :bin_files # :nodoc:
  attr_accessor :changes
  attr_accessor :clean_globs
  attr_accessor :description
  attr_accessor :description_sections
  attr_accessor :email
  attr_accessor :extra_deps
  attr_accessor :extra_dev_deps
  attr_accessor :lib_files # :nodoc:
  attr_accessor :multiruby_skip
  attr_accessor :name
  attr_accessor :need_tar
  attr_accessor :need_zip
  attr_accessor :post_install_message
  attr_accessor :rdoc_pattern
  attr_accessor :remote_rdoc_dir
  attr_accessor :rsync_args
  attr_accessor :rubyforge_name
  attr_accessor :spec # :nodoc:
  attr_accessor :spec_extras
  attr_accessor :summary
  attr_accessor :summary_sentences
  attr_accessor :test_files # :nodoc:
  attr_accessor :test_globs
  attr_accessor :testlib
  attr_accessor :url
  attr_accessor :version

  ##
  # Add extra dirs to both $: and RUBY_FLAGS (for test runs)

  def self.add_include_dirs(*dirs)
    dirs = dirs.flatten
    $:.unshift(*dirs)
    s = File::PATH_SEPARATOR
    Hoe::RUBY_FLAGS.sub!(/-I/, "-I#{dirs.join(s)}#{s}")
  end

  def normalize_deps deps
    Array(deps).map { |o| String === o ? [o] : o }
  end

  def missing name
    warn "** #{name} is missing or in the wrong format for auto-intuiting."
    warn "   run `sow blah` and look at its text files"
  end

  def initialize(name, version) # :nodoc:
    self.name = name
    self.version = version

    # Defaults
    self.author = []
    self.clean_globs = %w(diff diff.txt email.txt ri deps .source_index
                          *.gem *~ **/*~ *.rbc **/*.rbc)
    self.description_sections = %w(description)
    self.email = []
    self.extra_deps = []
    self.extra_dev_deps = []
    self.multiruby_skip = []
    self.need_tar = true
    self.need_zip = false
    self.rdoc_pattern = /^(lib|bin|ext)|txt$/
    self.remote_rdoc_dir = name
    self.rsync_args = '-av --delete'
    self.rubyforge_name = name.downcase
    self.spec_extras = {}
    self.summary_sentences = 1
    self.test_globs = ['test/**/test_*.rb']
    self.testlib = 'test/unit'
    self.post_install_message = nil

    yield self if block_given?

    # Intuit values:

    readme   = File.read("README.txt").split(/^(=+ .*)$/)[1..-1] rescue ''
    unless readme.empty? then
      sections = readme.map { |s|
        s =~ /^=/ ? s.strip.downcase.chomp(':').split.last : s.strip
      }
      sections = Hash[*sections]
      desc = sections.values_at(*description_sections).join("\n\n")
      summ = desc.split(/\.\s+/).first(summary_sentences).join(". ")

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

    %w(email author).each do |field|
      value = self.send(field)
      if value.nil? or value.empty? then
        if Time.now < Time.local(2008, 4, 1) then
          warn "Hoe #{field} value not set - Fix by 2008-04-01!"
          self.send "#{field}=", "doofus"
        else
          abort "Hoe #{field} value not set. aborting"
        end
      end
    end

    hoe_deps = {
      'rake' => ">= #{RAKEVERSION}",
      'rubyforge' => ">= #{::RubyForge::VERSION}",
    }

    self.extra_deps     = normalize_deps extra_deps
    self.extra_dev_deps = normalize_deps extra_dev_deps

    if name == 'hoe' then
      hoe_deps.each do |pkg, vers|
        extra_deps << [pkg, vers]
      end
    else
      extra_dev_deps << ['hoe', ">= #{VERSION}"] unless hoe_deps.has_key? name
    end

    define_tasks
  end

  def developer name, email
    self.author << name
    self.email << email
  end

  def with_config # :nodoc:
    rc = File.expand_path("~/.hoerc")
    exists = File.exist? rc
    config = exists ? YAML.load_file(rc) : {}
    yield(config, rc)
  end

  def define_tasks # :nodoc:
    signing_key = nil
    cert_chain = []

    with_config do |config, path|
      break unless config['signing_key_file'] and config['signing_cert_file']
      key_file = File.expand_path config['signing_key_file'].to_s
      signing_key = key_file if File.exist? key_file

      cert_file = File.expand_path config['signing_cert_file'].to_s
      cert_chain << cert_file if File.exist? cert_file
    end

    self.spec = Gem::Specification.new do |s|
      s.name = name
      s.version = version
      s.summary = summary
      case author
      when Array
        s.authors = author
      else
        s.author = author
      end
      s.email = email
      s.homepage = Array(url).first
      s.rubyforge_project = rubyforge_name

      s.description = description

      extra_deps.each do |dep|
        s.add_dependency(*dep)
      end

      extra_dev_deps.each do |dep|
        s.add_development_dependency(*dep)
      end

      s.files = File.read("Manifest.txt").delete("\r").split(/\n/)
      s.executables = s.files.grep(/^bin/) { |f| File.basename(f) }

      s.bindir = "bin"
      dirs = Dir['{lib,ext}']
      s.require_paths = dirs unless dirs.empty?

      s.rdoc_options = ['--main', 'README.txt']
      s.extra_rdoc_files = s.files.grep(/txt$/)
      s.has_rdoc = true

      s.post_install_message = post_install_message

      if test ?f, "test/test_all.rb" then
        s.test_file = "test/test_all.rb"
      else
        s.test_files = Dir[*test_globs]
      end

      if signing_key and cert_chain then
        s.signing_key = signing_key
        s.cert_chain = cert_chain
      end

      ############################################################
      # Allow automatic inclusion of compiled extensions
      if ENV['INLINE'] then
        s.platform = ENV['FORCE_PLATFORM'] || Gem::Platform::CURRENT

        # Try collecting Inline extensions for +name+
        if defined?(Inline) then
          directory 'lib/inline'

          Inline.registered_inline_classes.each do |cls|
            name = cls.name # TODO: what about X::Y::Z?
            # name of the extension is CamelCase
            alternate_name = if name =~ /[A-Z]/ then
                               name.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, '')
                             elsif name =~ /_/ then
                               name.capitalize.gsub(/_([a-z])/) { $1.upcase }
                             end

            extensions = Dir.chdir(Inline::directory) {
              Dir["Inline_{#{name},#{alternate_name}}_*.#{DLEXT}"]
            }

            extensions.each do |ext|
              # add the inlined extension to the spec files
              s.files += ["lib/inline/#{ext}"]

              # include the file in the tasks
              file "lib/inline/#{ext}" => ["lib/inline"] do
                cp File.join(Inline::directory, ext), "lib/inline"
              end
            end
          end
        end
      end

      # Do any extra stuff the user wants
      spec_extras.each do |msg, val|
        case val
        when Proc
          val.call(s.send(msg))
        else
          s.send "#{msg}=", val
        end
      end
    end

    self.lib_files = spec.files.grep(/^(lib|ext)/)
    self.bin_files = spec.files.grep(/^bin/)
    self.test_files = spec.files.grep(/^test/)

    Rake::GemPackageTask.new spec do |pkg|
      pkg.need_tar = @need_tar
      pkg.need_zip = @need_zip
    end

    desc 'Install the package as a gem.'
    task :install_gem => [:clean, :package] do
      gem = Dir['pkg/*.gem'].first
      sh "#{'sudo ' unless WINDOZE}gem install --local #{gem}"
    end

    desc 'Package and upload the release to rubyforge.'
    task :release => [:clean, :package] do |t|
      v = ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
      abort "Versions don't match #{v} vs #{version}" if v != version
      pkg = "pkg/#{name}-#{version}"

      if $DEBUG then
        puts "release_id = rf.add_release #{rubyforge_name.inspect}, #{name.inspect}, #{version.inspect}, \"#{pkg}.tgz\""
        puts "rf.add_file #{rubyforge_name.inspect}, #{name.inspect}, release_id, \"#{pkg}.gem\""
      end

      rf = RubyForge.new.configure
      puts "Logging in"
      rf.login

      c = rf.userconfig
      c["release_notes"] = description if description
      c["release_changes"] = changes if changes
      c["preformatted"] = true

      files = [(@need_tar ? "#{pkg}.tgz" : nil),
               (@need_zip ? "#{pkg}.zip" : nil),
               "#{pkg}.gem"].compact

      puts "Releasing #{name} v. #{version}"
      rf.add_release rubyforge_name, name, version, *files
    end

    ############################################################
    # Doco

    desc 'Generate ri locally for testing.'
    task :ridocs => :clean do
      sh %q{ rdoc --ri -o ri . }
    end

    Rake::RDocTask.new('rdoc') do |rd|
      rd.main = "README.txt"
      rd.rdoc_dir = 'doc'
      files = spec.files.grep(rdoc_pattern)
      files -= ['Manifest.txt']
      rd.rdoc_files.push(*files)

      title = "#{name}-#{version} Documentation"
      title = "#{rubyforge_name}'s " + title if rubyforge_name != name

      rd.options << "-t #{title}"
      rd.template = '/usr/lib/ruby/gems/1.8/gems/allison-2.0.3/lib/allison'
    end

    desc 'Publish RDoc to RubyForge.'
    task :publish_docs => [:clean, 'rdoc'] do
      config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
      host = "#{config["username"]}@rubyforge.org"

      remote_dir = "/var/www/gforge-projects/#{rubyforge_name}/#{remote_rdoc_dir}"
      local_dir = 'doc'

      sh %{rsync #{rsync_args} #{local_dir}/ #{host}:#{remote_dir}}
    end

    desc 'Clean up all the extras.'
    task :clean => [ :clobber_package ] do
      clean_globs.each do |pattern|
        files = Dir[pattern]
        rm_rf files, :verbose => true unless files.empty?
      end
    end

    task :email do
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

    task :post_news do
      subject, title, body, urls = announcement

      rf = RubyForge.new.configure
      rf.login
      rf.post_news(rubyforge_name, subject, "#{title}\n\n#{body}")
      puts "Posted to rubyforge"
    end

    desc 'Post news to rubyforge and create email announcement'
    task :announce => [:email, :post_news]

    desc 'Generate a key for signing your gems.'
    task :generate_key do
      email = spec.email
      abort "No email in your gemspec" if email.nil? or email.empty?

      key_file = with_config { |config, _| config['signing_key_file'] }
      cert_file = with_config { |config, _| config['signing_cert_file'] }

      if key_file.nil? or cert_file.nil? then
        ENV['SHOW_EDITOR'] ||= 'no'
        Rake::Task['config_hoe'].invoke

        key_file = with_config { |config, _| config['signing_key_file'] }
        cert_file = with_config { |config, _| config['signing_cert_file'] }
      end

      key_file = File.expand_path key_file
      cert_file = File.expand_path cert_file

      unless File.exist? key_file or File.exist? cert_file then
        sh "gem cert --build #{email}"
        mv "gem-private_key.pem", key_file, :verbose => true
        mv "gem-public_cert.pem", cert_file, :verbose => true

        puts "Installed key and certificate."

        rf = RubyForge.new.configure
        rf.login

        cert_package = "#{rubyforge_name}-certificates"

        begin
          rf.lookup 'package', cert_package
        rescue
          rf.create_package rubyforge_name, cert_package
        end

        begin
          rf.lookup('release', cert_package)['certificates']
          rf.add_file rubyforge_name, cert_package, 'certificates', cert_file
        rescue
          rf.add_release rubyforge_name, cert_package, 'certificates', cert_file
        end

        puts "Uploaded certificate to release \"certificates\" in package #{cert_package}"
      else
        puts "Keys already exist."
      end
    end

  end # end define

  def announcement # :nodoc:
    changes = self.changes.rdoc_to_markdown
    subject = "#{name} #{version} Released"
    title   = "#{name} version #{version} has been released!"
    body    = "#{description}\n\nChanges:\n\n#{changes}".rdoc_to_markdown
    urls    = Array(url).map { |s| "* <#{s.strip.rdoc_to_markdown}>" }.join("\n")

    return subject, title, body, urls
  end

  def run_tests(multi=false) # :nodoc:
    msg = multi ? :sh : :ruby
    cmd = if test ?f, 'test/test_all.rb' then
            "#{RUBY_FLAGS} test/test_all.rb #{FILTER}"
          else
            tests = ["rubygems", self.testlib] +
              test_globs.map { |g| Dir.glob(g) }.flatten
            tests.map! {|f| %Q(require "#{f}")}
            "#{RUBY_FLAGS} -e '#{tests.join("; ")}' #{FILTER}"
          end

    excludes = multiruby_skip.join(":")
    ENV['EXCLUDED_VERSIONS'] = excludes
    cmd = "multiruby #{cmd}" if multi

    send msg, cmd
  end

  ##
  # Reads a file at +path+ and spits out an array of the +paragraphs+ specified.
  #
  #   changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  #   summary, *description = p.paragraphs_of('README.txt', 3, 3..8)

  def paragraphs_of(path, *paragraphs)
    File.read(path).delete("\r").split(/\n\n+/).values_at(*paragraphs)
  end
end

# :enddoc:

class ::Rake::SshDirPublisher # :nodoc:
  attr_reader :host, :remote_dir, :local_dir
end

class String
  def rdoc_to_markdown
    self.gsub(/^mailto:/, '').gsub(/^(=+)/) { "#" * $1.size }
  end
end

require 'rubigen'
require 'reek/version'

AUTHOR = 'Kevin Rutherford'
EMAIL = "kevin@rutherford-software.com"
DESCRIPTION = "detects smells in Ruby code"
GEM_NAME = 'reek' # what ppl will type to install your gem
RUBYFORGE_PROJECT = 'reek' # The unix name for your project
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
DOWNLOAD_PATH = "http://rubyforge.org/projects/#{RUBYFORGE_PROJECT}"

@config_file = "~/.rubyforge/user-config.yml"
@config = nil
RUBYFORGE_USERNAME = "unknown"
def rubyforge_username
  unless @config
    begin
      @config = YAML.load(File.read(File.expand_path(@config_file)))
    rescue
      puts <<-EOS
ERROR: No rubyforge config file found: #{@config_file}
Run 'rubyforge setup' to prepare your env for access to Rubyforge
 - See http://newgem.rubyforge.org/rubyforge.html for more details
      EOS
      exit
    end
  end
  RUBYFORGE_USERNAME.replace @config["username"]
end

VERS = Reek::VERSION::STRING
RDOC_OPTS = ['--quiet', '--title', 'reek documentation',
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

class Hoe
  def extra_deps 
    @extra_deps.reject! { |x| Array(x).first == 'hoe' } 
    @extra_deps
  end 
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERS) do |p|
  p.developer(AUTHOR, EMAIL)
  p.description = DESCRIPTION
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/test_*.rb"]
  p.clean_globs |= ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store']  #An array of file patterns to delete on clean.
  
  # == Optional
  p.changes = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.extra_deps = [['ParseTree', '~> 3.0'], ['sexp_processor', '~> 3.0']]

  #p.spec_extras = {}    # A hash of extra values to set in the gemspec.
  
end

CHANGES = hoe.paragraphs_of('History.txt', 0..1).join("\\n\\n")
PATH    = RUBYFORGE_PROJECT
hoe.remote_rdoc_dir = File.join(PATH.gsub(/^#{RUBYFORGE_PROJECT}\/?/,''), 'rdoc')
hoe.rsync_args = '-av --delete --ignore-errors'
