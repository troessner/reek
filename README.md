# `reek`: code smell detection for Ruby

## Overview


[![Build Status](https://secure.travis-ci.org/troessner/reek.png?branch=master)](https://travis-ci.org/troessner/reek?branch=master)
[![Gem Version](https://badge.fury.io/rb/reek.svg)](https://badge.fury.io/rb/reek)
[![Dependency Status](https://gemnasium.com/troessner/reek.png)](https://gemnasium.com/troessner/reek)
[![Inline docs](https://inch-ci.org/github/troessner/reek.png)](https://inch-ci.org/github/troessner/reek)

## Quickstart

`reek` is a tool that examines Ruby classes, modules and methods and reports any
[Code Smells](docs/Code-Smells.md) it finds.
Install it like this:

```Bash
gem install reek
```

and run it like this:

```Bash
reek [options] [dir_or_source_file]*
```

## Example

Imagine a source file `demo.rb` containing:

```Ruby
class Dirty
  # This method smells of :reek:NestedIterators but ignores them
  def awful(x, y, offset = 0, log = false)
    puts @screen.title
    @screen = widgets.map { |w| w.each { |key| key += 3 * x } }
    puts @screen.contents
  end
end
```

`reek` will report the following code smells in this file:

```
$ reek demo.rb
demo.rb -- 8 warnings:
  [1]:Dirty has no descriptive comment (IrresponsibleModule)
  [3]:Dirty#awful has 4 parameters (LongParameterList)
  [3]:Dirty#awful has boolean parameter 'log' (BooleanParameter)
  [3]:Dirty#awful has the parameter name 'x' (UncommunicativeParameterName)
  [5]:Dirty#awful has the variable name 'w' (UncommunicativeVariableName)
  [3]:Dirty#awful has unused parameter 'log' (UnusedParameters)
  [3]:Dirty#awful has unused parameter 'offset' (UnusedParameters)
  [3]:Dirty#awful has unused parameter 'y' (UnusedParameters)
```

## Sources

There are multiple ways you can have `reek` work on sources, the most common one just being

```Bash
reek lib/
```

If you don't pass any source arguments to `reek` it just takes the current working directory as source.

So

```Bash
reek
```

is the exact same thing as being explicit:

```Bash
reek .
```

Additionally you can pipe code to `reek` like this:

```Bash
echo "class C; def m; end; end" | reek
```

This would print out:

```Bash
$stdin -- 3 warnings:
  [1]:C has no descriptive comment (IrresponsibleModule)
  [1]:C has the name 'C' (UncommunicativeModuleName)
  [1]:C#m has the name 'm' (UncommunicativeMethodName)
```

## Code smells

`reek` currently includes checks for some aspects of
[Control Couple](docs/Control-Couple.md),
[Data Clump](docs/Data-Clump.md),
[Feature Envy](docs/Feature-Envy.md),
[Large Class](docs/Large-Class.md),
[Long Parameter List](docs/Long-Parameter-List.md),
[Simulated Polymorphism](docs/Simulated-Polymorphism.md),
[Too Many Statements](docs/Too-Many-Statements.md),
[Uncommunicative Name](docs/Uncommunicative-Name.md),
[Unused Parameters](docs/Unused-Parameters.md)
and more. See the [Code Smells](docs/Code-Smells.md)
for up to date details of exactly what `reek` will check in your code.

## Configuration

### Command-line interface

For a basic overview, run

```Ruby
reek --help
```

For a summary of those CLI options see [Command-Line Options](docs/Command-Line-Options.md).

### Configuration file

#### Configuration loading

Configuring `reek` via a configuration file is by far the most powerful way.

There are three ways of passing `reek` a configuration file:

1. Using the CLI `-c` switch (see [_Command-line interface_](#command-line-interface) above)
2. Having a file ending with `.reek` either in your current working directory or in a parent directory (more on that later)
3. Having a file ending with `.reek` in your home directory

The order in which `reek` tries to find such a configuration
file is exactly the above: first it checks if we have given
it a configuration file explicitly via CLI; then it checks
the current working directory for a file and if it can't
find one, it traverses up the directories until it hits the
root directory; lastly, it checks your home directory.

As soon as `reek` detects a configuration file it stops searching
immediately, meaning that from `reek`'s point of view there exists
exactly one configuration file and one configuration, regardless
of how many `*.reek` files you might have on your filesystem.

#### Configuration options

The first thing you probably want to check out are the
[Basic Smell Options](docs/Basic-Smell-Options.md)
which are supported by every smell type. Certain smell
types offer a configuration that goes beyond that
of the basic smell options, for instance
[Data Clump](docs/Data-Clump.md).
All options that go beyond the [Basic Smell Options](docs/Basic-Smell-Options.md)
should be documented in the corresponding smell type wiki page,
but if you want to get a quick and full overview over all possible
configurations you can always check out [the `config/default.reek`
file in this repository](config/defaults.reek).

Here's an excerpt of a `reek` configuration file from a commercial project:

```yaml
---
IrresponsibleModule:
  enabled: false

NestedIterators:
  exclude:
    - "ActiveModelErrorAdder#self.run" # should be refactored
    - "BookingRequests::Transfer#remote_validation"
    - "BookingRequestsController#vehicle_options" # respond_to block
    - "Content::Base#self.expose_fields" # unavoidable due to metaprogramming

DataClump:
  max_copies: 3
  min_clump_size: 3
```

### Source code comments

`reek` is not the police. In case you need to suppress a smell
warning and you can't or don't want to use configuration files for
whatever reasons you can also use source code comments like this:

```Ruby
# This method smells of :reek:NestedIterators
def smelly_method foo
  foo.each {|bar| bar.each {|baz| baz.qux}}
end
```

This is further explained under [Smell Suppresion](docs/Smell-Suppression.md).


## Integration

Besides the obvious

```Bash
reek [options] [dir_or_source_file]*
```

there are quite a few other ways how to use `reek` in your projects:

* Use `reek`'s [Rake task](docs/Rake-Task.md) to automate detecting code smells
* Add `reek`'s custom matcher to your [RSpec examples](docs/RSpec-matchers.md)
* Include `reek` using the [Developer API](docs/API.md)

## Developing `reek` / Contributing

The first thing you want to do after checking out the source code is to run Bundler:

```
bundle install
```

and then run the tests:

```bash
bundle exec rspec spec/your/file_spec.rb            # Runs all tests in spec/your/file_spec.rb
bundle exec rspec spec/your/file_spec.rb:23         # Runs test in line 23
bundle exec cucumber features/your_file.feature     # Runs all scenarios in your_file.feature
bundle exec cucumber features/your_file.feature:23  # Runs scenario at line 23
```

Or just run the whole test suite:

```
bundle exec rake
```

From then on you should check out:
* [How reek works internally](docs/How-reek-works-internally.md)
* [the contributing guide](CONTRIBUTING.md)


If you don't feel like getting your hands dirty with code there are still other ways you can help us:

* Open up an [issue](https://github.com/troessner/reek/issues) and report bugs
* Suggest other improvements like additional smells for instance

## Output formats

`reek` supports 5 output formats:

* plain text (default)
* HTML (`--format html`)
* YAML (`--format yaml`, see also [YAML Reports](docs/YAML-Reports.md))
* JSON (`--format json`)
* XML  (`--format xml`)

## Working with Rails

With current versions of `reek` it's best to examine only your `app/models` folder, because `reek` raises false positives against views and controllers.

For example, `params` is a kind of DTO (data transfer object) close to the system boundary, and so its characteristics should be different than regular code. But Reek doesn't know that (yet); `reek` thinks that all those `params[:something]` calls are a problem, and reports them as smells.

We plan to improve Reek in the near future so that it plays better with Rails. For now though, your best bet is to restrict it to looking at `app/models` and `lib`.

## Additional resources

### Tools

* [Vim plugin for `reek`](https://github.com/rainerborene/vim-reek)
* [TextMate Bundle for `reek`](https://github.com/peeyush1234/reek.tmbundle)
* [Colorful output for `reek`](https://github.com/joenas/preek)
  (also with [Guard::Preek](https://github.com/joenas/guard-preek))
* [Atom plugin for `reek`](https://atom.io/packages/linter-reek)
* [overcommit, a Git commit hook manager with support for
  `reek`](https://github.com/brigade/overcommit)

### Miscellaneous

* [Reek Driven Development](docs/Reek-Driven-Development.md)
* [Versioning policy](docs/Versioning-Policy.md)

### More information

* [Stack Overflow](https://stackoverflow.com/questions/tagged/reek)
* [RubyDoc.info](http://www.rubydoc.info/gems/reek)

## Contributors

A non-exhaustive list:

* Kevin Rutherford
* Matijs van Zuijlen
* Andrew Wagner
* Gilles Leblanc
* Timo Rößner
