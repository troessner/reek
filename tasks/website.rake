task :website_generate do
  (Dir['website/**/*.txt'] - Dir['website/version*.txt']).each do |txt|
    sh %{ruby script/txt2html #{txt} > #{txt.gsub(/txt$/,'html')} }
  end
end

task :website_upload do
  host = "#{rubyforge_username}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{PATH}/"
  local_dir = 'website'
  sh %{rsync -aCv #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Generate and upload website and rdoc'
task :website => [:website_generate, :website_upload, :publish_docs]
