require_relative 'lib/reek/version'

Gem::Specification.new do |spec|
  spec.name = 'reek'
  spec.version = Reek::Version::STRING
  spec.authors = ['Kevin Rutherford', 'Timo Roessner', 'Matijs van Zuijlen', 'Piotr Szotkowski']
  spec.email = ['timo.roessner@googlemail.com']

  spec.summary = 'Code smell detector for Ruby'
  spec.description =
    'Reek is a tool that examines Ruby classes, modules and methods and reports ' \
    'any code smells it finds.'
  spec.homepage = 'https://github.com/troessner/reek'
  spec.license = 'MIT'

  spec.extra_rdoc_files = ['CHANGELOG.md', 'License.txt']
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|samples|docs|tasks)/}) }
  end

  spec.executables = spec.files.grep(%r{^bin/}).map { |path| File.basename(path) }
  spec.rdoc_options = %w(--main README.md -x assets/|bin/|config/|features/|spec/|tasks/)
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/troessner/reek',
    'source_code_uri'       => 'https://github.com/troessner/reek',
    'bug_tracker_uri'       => 'https://github.com/troessner/reek/issues',
    'changelog_uri'         => 'https://github.com/troessner/reek/CHANGELOG.md',
    'documentation_uri'     => 'https://www.rubydoc.info/gems/reek',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_runtime_dependency 'kwalify', '~> 0.7.0'
  spec.add_runtime_dependency 'parser',  '~> 3.1.0'
  spec.add_runtime_dependency 'rainbow', '>= 2.0', '< 4.0'
end
