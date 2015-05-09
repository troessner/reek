# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'lib/reek/version')

Gem::Specification.new do |s|
  s.name = 'reek'
  s.version = Reek::Version::STRING

  s.authors = ['Kevin Rutherford', 'Timo Roessner', 'Matijs van Zuijlen']
  s.default_executable = 'reek'
  s.description = <<-DESC
    Reek is a tool that examines Ruby classes, modules and methods and reports
    any code smells it finds.
  DESC

  s.license = 'MIT'
  s.email = ['timo.roessner@googlemail.com']
  s.extra_rdoc_files = ['CHANGELOG', 'License.txt']
  s.files = `git ls-files -z`.split("\0")
  s.executables = s.files.grep(%r{^bin/}).map { |path| File.basename(path) }
  s.homepage = 'https://github.com/troessner/reek/wiki'
  s.rdoc_options = %w(--main README.md -x assets/|bin/|config/|features/|spec/|tasks/)
  s.required_ruby_version = '>= 1.9.3'
  s.summary = 'Code smell detector for Ruby'

  s.add_runtime_dependency 'parser',   '~> 2.2'
  s.add_runtime_dependency 'rainbow',  '~> 2.0'
  s.add_runtime_dependency 'unparser', '~> 0.2.2'

  s.add_development_dependency 'activesupport', '~> 4.2'
  s.add_development_dependency 'aruba',         '~> 0.6.2'
  s.add_development_dependency 'bundler',       '~> 1.1'
  s.add_development_dependency 'cucumber',      '~> 2.0'
  s.add_development_dependency 'factory_girl',  '~> 4.0'
  s.add_development_dependency 'rake',          '~> 10.0'
  s.add_development_dependency 'rspec',         '~> 3.0'
  s.add_development_dependency 'rubocop',       '~> 0.30.0'
  s.add_development_dependency 'yard',          '~> 0.8.7'
end
