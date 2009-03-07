require 'newgem'
require 'reek'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('reek', ::Reek::VERSION) do |p|
  p.developer('Kevin Rutherford', 'kevin@rutherford-software.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = '
For more information on reek, see http://wiki.github.com/kevinrutherford/reek
'
  p.rubyforge_name       = p.name # TODO this is default value
  p.extra_deps         = [
    ['ParseTree', '~> 3.0'],
    ['sexp_processor', '~> 3.0']
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
  p.summary = 'Code smell detector for Ruby'
end
$hoe.spec.homepage = 'http://wiki.github.com/kevinrutherford/reek'

desc "Generate a #{$hoe.name}.gemspec file"
task :gemspec do
  File.open("#{$hoe.name}.gemspec", "w") do |file|
    file.puts $hoe.spec.to_ruby
  end
end

task :release do
  puts <<-EOS.gsub(/^  /,'')
  Remember to create tag your release; eg for Git:
    git tag REL-#{$hoe.version}
  
  Announce your release on RubyForge News:
    rake post_news
  EOS
end

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == $hoe.version
    puts "Please update your lib/#{$hoe.name}.rb to match the release version, currently #{$hoe.version}"
    exit
  end
end
