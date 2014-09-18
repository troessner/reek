# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__), "lib")
require 'reek/version'

Gem::Specification.new do |s|
  s.name = %q{reek}
  s.version = Reek::VERSION

  s.authors = ['Kevin Rutherford', 'Timo Roessner', 'Matijs van Zuijlen']
  s.default_executable = %q{reek}
  s.description = <<-DESC
    Reek is a tool that examines Ruby classes, modules and methods and reports
    any code smells it finds.
  DESC

  s.license = 'MIT'
  s.email = ["timo.roessner@googlemail.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["CHANGELOG", "License.txt"]
  s.files = Dir[".yardopts", "CHANGELOG", "License.txt", "README.md",
                "Rakefile", "assets/html_output.html.erb", "bin/reek", "config/defaults.reek",
                "{features,lib,spec,tasks}/**/*",
                "reek.gemspec" ] & `git ls-files -z`.split("\0")
  s.homepage = %q{http://wiki.github.com/troessner/reek}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{reek}
  s.rubygems_version = %q{1.3.6}
  s.required_ruby_version = %q{>= 1.9.2}
  s.summary = %q{Code smell detector for Ruby}

  s.add_runtime_dependency(%q<ruby_parser>, [">= 3.5.0", "< 4.0"])
  s.add_runtime_dependency(%q<sexp_processor>, ["~> 4.4"])
  s.add_runtime_dependency(%q<ruby2ruby>, [">= 2.0.8", "< 3.0"])
  s.add_runtime_dependency(%q<rainbow>, [">= 1.99", "< 3.0"])

  s.add_development_dependency(%q<bundler>, ["~> 1.1"])
  s.add_development_dependency(%q<rake>, ["~> 10.0"])
  s.add_development_dependency(%q<cucumber>, ["~> 1.3"])
  s.add_development_dependency(%q<rspec>, ["~> 3.0"])
  s.add_development_dependency(%q<flay>, ["~> 2.4"])
  s.add_development_dependency(%q<yard>, [">= 0.8.7", "< 0.9"])
end
