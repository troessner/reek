# Using Reek inside your Ruby application

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
examiner = Reek::Examiner.new source
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

## API stability

Everything that is mentioned in this document can be considered stable in the
sense that it will only change across major versions.

There is one thing in this API documentation you can't and shouldn't rely on:
The `SmellWarning` messages itself.

Something like this

```
Dirty#m has the parameter name 'a' (UncommunicativeParameterName)
```

might change even across minor versions.

You should not need to be specific about those messages anyways.
In case you'd like to be specific about `SmellWarnings` please have a look at
[accessing the smell warnings directly](#accessing-the-smell-warnings-directly).

Additionally you can use one of our structured [outputs formats](#choosing-your-output-format)
like JSON or YAML if you need a more fine-grained access to our
`SmellWarnings`.

## Choosing your output format

Besides normal text output, Reek can generate output in YAML,
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

Reek will load this file automatically by default. If you want to load the
configuration explicitely, you can use one of the methods below.

You can now use either

```Ruby
Reek::Configuration::AppConfiguration.from_path Pathname.new('config.reek')
```

but you can also pass a hash with the contents of the `config.reek` YAML file
to `Reek::Configuration::AppConfiguration.from_hash`.

Given the example above you would load that as follows:

```Ruby
require 'reek'

config_hash = { 'IrresponsibleModule' => { 'enabled' => false } }
configuration = Reek::Configuration::AppConfiguration.from_hash config_hash

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

This would now only report `UncommunicativeParameterName` but not
`IrresponsibleModule` for the `Dirty` class:

```
string -- 2 warnings:
  Dirty#call_me has the parameter name 'a' (UncommunicativeParameterName)
  Dirty#call_me has the parameter name 'b' (UncommunicativeParameterName)
```

Instead of the smell detector names you can also use the full detector class in
your configuration hash, for example:

```ruby
config_hash = { Reek::SmellDetectors::IrresponsibleModule => { 'enabled' => false } }
```

Of course, directory specific configuration and excluded paths are supported as
well:

```
config_hash = {
  'IrresponsibleModule' => { 'enabled' => false }
  'spec/samples/three_clean_files/' =>
    { 'UtilityFunction' => { "enabled" => false } }
  'exclude_paths' =>
    [ 'spec/samples/two_smelly_files' ]
}
```

## Accessing the smell warnings directly

You can also access the smells detected by an examiner directly:

```ruby
require 'reek'

source = <<-END
  class C
  end
END

examiner = Reek::Examiner.new source
examiner.smells.each do |smell|
  puts smell.message
end
```

`Examiner#smells` returns a list of `SmellWarning` objects.
