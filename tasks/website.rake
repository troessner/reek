require 'yaml'

desc 'Upload website files to rubyforge'
task :website_upload do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{$hoe.name}/"
  local_dir = 'website'
  sh %{rsync #{$hoe.rsync_args} #{local_dir}/ #{host}:#{remote_dir}}
end
