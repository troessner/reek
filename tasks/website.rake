require 'yaml'

desc 'Upload website files to rubyforge'
task :website_upload do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{PROJECT_NAME}/"
  local_dir = 'website'
  sh %{rsync -av --delete --ignore-errors #{local_dir}/ #{host}:#{remote_dir}}
end
