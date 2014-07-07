# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__), "lib")
require 'reek/version'

Gem::Specification.new do |s|
  s.name = %q{reek}
  s.version = Reek::VERSION

  s.authors = ['Kevin Rutherford', 'Timo Roessner', 'Matijs van Zuijlen']
  s.default_executable = %q{reek}
  s.description = %q{Reek is a tool that examines Ruby classes, modules and methods
and reports any code smells it finds.
}
  s.email = ["timo.roessner@googlemail.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["CHANGELOG", "License.txt"]
  s.files = Dir[".yardopts", "CHANGELOG", "License.txt", "README.md",
                "Rakefile", "bin/reek", "config/defaults.reek",
                "{features,lib,spec,tasks}/**/*",
                "reek.gemspec" ] & `git ls-files -z`.split("\0")
  s.homepage = %q{http://wiki.github.com/troessner/reek}
  s.post_install_message = %q{Thank you for downloading Reek. For info see the reek wiki http://wiki.github.com/troessner/reek}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{reek}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Code smell detector for Ruby}

  s.add_runtime_dependency(%q<ruby_parser>, ["~> 3.3"])
  s.add_runtime_dependency(%q<sexp_processor>)
  s.add_runtime_dependency(%q<ruby2ruby>, [">= 2.0.8", "< 3.0"])
  s.add_runtime_dependency(%q<rainbow>, [">= 1.99", "< 3.0"])

  s.add_development_dependency(%q<bundler>, ["~> 1.1"])
  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<cucumber>)
  s.add_development_dependency(%q<rspec>, ["~> 2.12"])
  s.add_development_dependency(%q<flay>)
  s.add_development_dependency(%q<yard>)
end
