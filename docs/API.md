# Using `reek` inside your Ruby application

## Installation

Either standalone via

```bash
gem install reek
```

or by adding

```
gem 'reek'
```

to your Gemfile.

## Quick start

Code says more than a thousand words:

```ruby
require 'reek'

source = <<-EOS
  class Dirty
    def m(a,b,c)
      puts a,b
    end
  end
EOS

reporter = Reek::Report::TextReport.new
examiner = Reek::Examiner.new(source)
reporter.add_examiner examiner
reporter.show
```

This would output the following on STDOUT:

```
string -- 5 warnings:
  Dirty has no descriptive comment (IrresponsibleModule)
  Dirty#m has the name 'm' (UncommunicativeMethodName)
  Dirty#m has the parameter name 'a' (UncommunicativeParameterName)
  Dirty#m has the parameter name 'b' (UncommunicativeParameterName)
  Dirty#m has unused parameter 'c' (UnusedParameters)
```

Note that `Reek::Examiner.new` can take `source` as `String`, `Pathname`, `File` or `IO`.

## Choosing your output format

Besides normal text output, `reek` can generate output in YAML,
JSON, HTML and XML by using the following Report types:

```
TextReport
YAMLReport
JSONReport
HTMLReport
XMLReport
```

## Configuration

Given you have the following configuration file called `config.reek` in your root directory:

```Yaml
---
IrresponsibleModule:
  enabled: false
```

You can now use either

```Ruby
Reek::Configuration::AppConfiguration.from_path Pathname.new('config.reek`)
```

but you can also pass a hash via `Reek::Configuration::AppConfiguration.from_map`.

This hash can have the following 3 keys:

1.) directory_directives [Hash] for instance:

```Ruby
  { Pathname("spec/samples/three_clean_files/") =>
    { Reek::Smells::UtilityFunction => { "enabled" => false } } }
```

2.) default_directive [Hash] for instance:

```Ruby
  { Reek::Smells::IrresponsibleModule => { "enabled" => false } }
```

3.) excluded_paths [Array] for instance:

```Ruby
  [ Pathname('spec/samples/two_smelly_files') ]
```

Given the example above you should load that as "default directive" which means that it will
be the default configuration for smell types for which there is
no "directory directive" (so a directory-specific configuration):

```Ruby
require 'reek'

default_directive = { Reek::Smells::IrresponsibleModule => { 'enabled' => false } }
configuration = Reek::Configuration::AppConfiguration.from_map default_directive: default_directive

source = <<-EOS
  class Dirty
    def call_me(a,b)
      puts a,b
    end
  end
EOS

reporter = Reek::Report::TextReport.new
examiner = Reek::Examiner.new(source, configuration: configuration); nil
reporter.add_examiner examiner; nil
reporter.show
```

This would now only report the `UncommunicativeParameterName` but not the `IrresponsibleModule`
for the `Dirty` class:

```
string -- 2 warnings:
  Dirty#call_me has the parameter name 'a' (UncommunicativeParameterName)
  Dirty#call_me has the parameter name 'b' (UncommunicativeParameterName)
```

## Accessing the smell warnings directly

You can also access the smells detected by an examiner directly:

```ruby
require 'reek'

source = <<-END
  class C
  end
END

examiner = Reek::Examiner.new(source)
examiner.smells.each do |smell|
  puts smell.message
end
```

`Examiner#smells` returns a list of `SmellWarning` objects.
