require 'yaml'
require 'rubyforge'

REMOTE_PROJECT_DIR = "/var/www/gforge-projects/#{PROJECT_NAME}/"

def user_at_host
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  "#{config["username"]}@rubyforge.org"
end

def rsync(local, remote)
  sh %{rsync -av --delete --ignore-errors #{local}/ #{user_at_host}:#{remote}}
end

namespace :rubyforge do
  desc 'Upload website files to rubyforge'
  task :website do
    rsync('website', REMOTE_PROJECT_DIR)
  end

  desc 'Upload the gem to rubyforge'
  task :gem => ['build:package'] do |t|
    pkg = "#{PKG_DIR}/#{PROJECT_NAME}-#{::Reek::VERSION}"
    rf = RubyForge.new.configure
    rf.login
    c = rf.userconfig
    proj = Description.new
    c["release_notes"] = proj.description
    c["release_changes"] = proj.changes
    c["preformatted"] = true
    files = ["#{pkg}.tgz", "#{pkg}.gem"]
    rf.add_release(PROJECT_NAME, PROJECT_NAME, ::Reek::VERSION, *files)
  end

  desc 'Upload the rdoc to rubyforge'
  task :rdoc => ['build:rdoc'] do
    rsync(RDOC_DIR, "#{REMOTE_PROJECT_DIR}/rdoc")
  end

  desc 'Post news announcement to rubyforge'
  task :news do
    proj = Description.new
    rf = RubyForge.new.configure
    rf.login
    puts "rf.post_news(#{PROJECT_NAME}, #{proj.subject}, #{proj.news})"
  end
end
