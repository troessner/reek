require 'yaml'
require 'rubyforge'

REMOTE_PROJECT_DIR = "/var/www/gforge-projects/#{PROJECT_NAME}/"

def user_at_host
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  "#{config["username"]}@rubyforge.org"
end

namespace :rubyforge do
  desc 'Upload website files to rubyforge'
  task :website do
    sh %{rsync -av --delete --ignore-errors website/ #{user_at_host}:#{REMOTE_PROJECT_DIR}}
  end

  desc 'Upload the gem to rubyforge'
  task :gem => ['clean', 'build:package'] do |t|
    pkg = "#{PKG_DIR}/#{PROJECT_NAME}-#{::Reek::VERSION}"
    rf = RubyForge.new.configure
    puts "Logging in"
    rf.login
    c = rf.userconfig
    c["release_notes"] = @description if @description     # TODO!!
    c["release_changes"] = changes if changes
    c["preformatted"] = true
    files = ["#{pkg}.tgz", "#{pkg}.gem"].compact
    puts "Releasing #{PROJECT_NAME} v. #{::Reek::VERSION}"
    rf.add_release(PROJECT_NAME, PROJECT_NAME, ::Reek::VERSION, *files)
  end

  desc 'Upload the rdoc to rubyforge'
  task :rdoc => ['clean', 'build:rdoc'] do
    sh %{rsync -av --delete --ignore-errors #{RDOC_DIR}/ #{user_at_host}:#{REMOTE_PROJECT_DIR}/rdoc}
  end
end
