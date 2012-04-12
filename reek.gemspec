# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'lib/reek/version.rb')

Gem::Specification.new do |s|
  s.name = %q{reek}
  s.version = Reek::VERSION

  s.authors = ["Kevin Rutherford"]
  s.date = %q{2010-04-26}
  s.default_executable = %q{reek}
  s.description = "Reek is a tool that examines Ruby classes, modules and methods and reports any code smells it finds."
  s.email = ["kevin@rutherford-software.com"]
  s.executables = ["reek"]
  s.extra_rdoc_files = ["History.txt", "License.txt"]
  s.files = Dir[".yardopts", "History.txt", "License.txt", "README.md",
                "Rakefile", "bin/reek", "config/defaults.reek",
                "{features,lib,spec,tasks}/**/*",
                "reek.gemspec" ] & `git ls-files -z`.split("\0")
  s.homepage = %q{http://wiki.github.com/kevinrutherford/reek}
  s.post_install_message = %q{
Thank you for downloading Reek. For info:
  - see the reek wiki http://wiki.github.com/kevinrutherford/reek
  - follow @rubyreek on twitter
}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{reek}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Code smell detector for Ruby}

  s.add_runtime_dependency(%q<ruby_parser>, ["~> 2.0"])
  s.add_runtime_dependency(%q<ruby2ruby>, ["~> 1.3"])
  s.add_runtime_dependency(%q<sexp_processor>, ["~> 3.0"])

  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<cucumber>)
  s.add_development_dependency(%q<rspec>, [">= 1.3.2"])
end
