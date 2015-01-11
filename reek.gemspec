# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.join(File.dirname(__FILE__), 'lib')
require 'reek/version'

Gem::Specification.new do |s|
  s.name = 'reek'
  s.version = Reek::VERSION

  s.authors = ['Kevin Rutherford', 'Timo Roessner', 'Matijs van Zuijlen']
  s.default_executable = 'reek'
  s.description = <<-DESC
    Reek is a tool that examines Ruby classes, modules and methods and reports
    any code smells it finds.
  DESC

  s.license = 'MIT'
  s.email = ['timo.roessner@googlemail.com']
  s.executables = ['reek']
  s.extra_rdoc_files = ['CHANGELOG', 'License.txt']
  s.files = Dir['.yardopts', 'CHANGELOG', 'License.txt', 'README.md',
                'Rakefile', 'assets/html_output.html.erb', 'bin/reek',
                'config/defaults.reek', '{features,lib,spec,tasks}/**/*',
                'reek.gemspec'] & `git ls-files -z`.split("\0")
  s.homepage = 'http://wiki.github.com/troessner/reek'
  s.rdoc_options = ['--main', 'README.md',
                    '-x', 'assets/|bin/|config/|features/|spec/|tasks/']
  s.require_paths = ['lib']
  s.rubyforge_project = 'reek'
  s.rubygems_version = '1.3.6'
  s.required_ruby_version = '>= 1.9.3'
  s.summary = 'Code smell detector for Ruby'

  s.add_runtime_dependency('parser', ['~> 2.2.0.pre.7'])
  s.add_runtime_dependency('unparser', ['= 0.1.16'])
  s.add_runtime_dependency('rainbow', ['>= 1.99', '< 3.0'])

  s.add_development_dependency('bundler', ['~> 1.1'])
  s.add_development_dependency('rake', ['~> 10.0'])
  s.add_development_dependency('cucumber', ['~> 1.3'])
  s.add_development_dependency('rspec', ['~> 3.0'])
  s.add_development_dependency('yard', ['>= 0.8.7', '< 0.9'])
  s.add_development_dependency('factory_girl', ['~> 4.0'])
  s.add_development_dependency('rubocop', ['~> 0.28.0'])
end
