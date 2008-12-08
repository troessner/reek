desc 'Release the website and new gem version'
task :deploy => [:check_version, :website, :release] do
  puts "Remember to tag git!"
end

desc 'Runs tasks website_generate and install_gem as a local deployment of the gem'
task :local_deploy => [:website_generate, :install_gem]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end

namespace :manifest do
  desc 'Verify the manifest'
  task :check => :clean do
    f = "Manifest.tmp"
    require 'find'
    files = []
    Find.find '.' do |path|
      next unless File.file? path
      next if path =~ /tmp$|\.git/
      files << path[2..-1]
    end
    files = files.sort.join("\n")
    File.open(f, 'w') { |fp| fp.puts files }
    system "diff -du Manifest.txt #{f}"
    rm f
  end
end
