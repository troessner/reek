# Reek -- code smell detection for Ruby

## Overview


[![Build Status](https://secure.travis-ci.org/troessner/reek.png?branch=master)](http://travis-ci.org/troessner/reek?branch=master)
[![Gem Version](https://badge.fury.io/rb/reek.png)](http://badge.fury.io/rb/reek)
[![Dependency Status](https://gemnasium.com/troessner/reek.png)](https://gemnasium.com/troessner/reek)
[![Inline docs](http://inch-ci.org/github/troessner/reek.png)](http://inch-ci.org/github/troessner/reek)

## Quickstart

`reek` is a tool that examines Ruby classes, modules and methods and reports any [Code Smells](https://github.com/troessner/reek/wiki/Code-Smells) it finds. Install it like this:

```Bash
gem install reek
```

and run it like this:

```Bash
reek [options] [dir_or_source_file]*
```

## Example

Imagine a source file <tt>demo.rb</tt> containing:

```Ruby
class Dirty
  # This method smells of :reek:NestedIterators but ignores them
  def awful(x, y, offset = 0, log = false)
    puts @screen.title
    @screen = widgets.map {|w| w.each {|key| key += 3}}
    puts @screen.contents
  end
end
```

Reek will report the following code smells in this file:

```
$ reek demo.rb
spec/samples/demo/demo.rb -- 6 warnings:
  Dirty has no descriptive comment (IrresponsibleModule)
  Dirty#awful has 4 parameters (LongParameterList)
  Dirty#awful has boolean parameter 'log' (ControlCouple)
  Dirty#awful has the parameter name 'x' (UncommunicativeName)
  Dirty#awful has the parameter name 'y' (UncommunicativeName)
  Dirty#awful has the variable name 'w' (UncommunicativeName)
  Dirty#awful has unused parameter 'log' (UnusedParameters)
  Dirty#awful has unused parameter 'offset' (UnusedParameters)
  Dirty#awful has unused parameter 'x' (UnusedParameters)
  Dirty#awful has unused parameter 'y' (UnusedParameters)
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

is the exact same thing like being explicit:

```Bash
reek .
```

Additionally can you pipe code to reek like this:

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

`reek` currently includes checks for some aspects of [Control Couple](https://github.com/troessner/reek/wiki/Control-Couple), [Data Clump](https://github.com/troessner/reek/wiki/Data-Clump), [Feature Envy](https://github.com/troessner/reek/wiki/Feature-Envy), [Large Class](https://github.com/troessner/reek/wiki/Large-Class), [Long Parameter List](https://github.com/troessner/reek/wiki/Long-Parameter-List), [Simulated Polymorphism](https://github.com/troessner/reek/wiki/Simulated-Polymorphism), [Too Many Statements](https://github.com/troessner/reek/wiki/Too-Many-Statements), [Uncommunicative Name](https://github.com/troessner/reek/wiki/Uncommunicative-Name), [Unused Parameters](https://github.com/troessner/reek/wiki/Unused-Parameters) and more. See the [Code Smells](https://github.com/troessner/reek/wiki/Code-Smells) for up to date details of exactly what `reek` will check in your code.

## Configuration

### Command line interface

For a basic overview, run

```Ruby
reek --help
```

For a summary of those CLI options see [Command-Line Options](https://github.com/troessner/reek/wiki/Command-Line-Options).

### Configuration files

#### Configuration loading

Configuring `reek` via configuration file is by far the most powerful way.

There are 3 ways of passing `reek` a configuration file:

1. Using the cli "-c" switch (see "Command line interface" above)
2. Having a file ending with .reek either in your current working directory or in a parent directory (more on that later)
3. Having a file ending with .reek in your HOME directory

The order in which `reek` tries to find such a configuration file is exactly like above: First `reek` checks if we have given it a configuration file explicitly via CLI. Then it checks the current working directory for a file and if it can't find one, it traverses up the directories until it hits the root directory. And lastly, it checks your HOME directory.

As soon as `reek` detects a configuration file it stops searching immediately, meaning that from `reek`'s point of view there exists one configuration file and one configuration only regardless of how many ".reek" files you might have on your filesystem.

#### Configuration options

The first thing you probably want to check out are the [Basic Smell Options](https://github.com/troessner/reek/wiki/Basic-Smell-Options) which are supported by every smell type.
Certain smell types offer a configuration that goes beyond that of the basic smell options - for instance [Data Clump](https://github.com/troessner/reek/wiki/Data-Clump).
All options that go beyond the [Basic Smell Options](https://github.com/troessner/reek/wiki/Basic-Smell-Options) should be documented in the corresponding smell type wiki page but if you want to get a quick and full overview over all possible configurations you can always check out [the default.reek file in this repository](https://github.com/troessner/reek/blob/master/config/defaults.reek).

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

`reek` is not the police. In case you need to suppress a smell warning and you can't or don't want to use configuration files for whatever reasons you can also use source code comments like this:

```Ruby
# This method smells of :reek:NestedIterators
def smelly_method foo
  foo.each {|bar| bar.each {|baz| baz.qux}}
end
```

This is further explained [here](https://github.com/troessner/reek/wiki/Smell-Suppression)


## Integration

Besides the obvious

```Bash
reek [options] [dir_or_source_file]*
```

there are quite a few other ways how to use reek in your projects:

* Use `reek`'s [Rake Task](https://github.com/troessner/reek/wiki/Rake-Task) to automate detecting code smells
* Add `reek`'s custom matcher to your [RSpec examples](https://github.com/troessner/reek/wiki/RSpec-Integration)
* Include `reek` using the [Developer API](https://github.com/troessner/reek/wiki/Developer-Api)

## Developing reek / Contributing

The first thing you want to do after checking out the source code is to run bundler

```
bundle install
```

and then to run the tests:

```bash
bundle exec rspec spec/your/file_spec.rb            # Runs all tests in spec/your/file_spec.rb
bundle exec rspec spec/your/file_spec.rb:23         # Runs test in line 23
bundle exec cucumber features/your_file.feature     # Runs all scenarios in your_file.feature
bundle exec cucumber features/your_file.feature:23  # Runs scenario at line 23
```

Or just run the whole test suite by running

```
bundle exec rake
```

From then on continue by following the establish [pull request workflow](https://help.github.com/articles/using-pull-requests/).

If you don't feel like getting your hands dirty with code there are still other ways you can help us:

* Work on the [wiki](https://github.com/troessner/reek/wiki)
* Open up an [issue](https://github.com/troessner/reek/issues) and report bugs or suggest other improvements

## Output formats

`reek` supports 3 output formats:

* plain text (default)
* html (-H, --html)
* yaml (-y, --yaml)

## Additional resources

### Tools

There's a vim plugin for `reek`:
[https://github.com/rainerborene/vim-reek](https://github.com/rainerborene/vim-reek)

TextMate Bundle for `reek`:
[https://github.com/peeyush1234/reek.tmbundle](https://github.com/peeyush1234/reek.tmbundle)

Colorful output for `reek`: [Preek](https://github.com/joenas/preek) (also with
[Guard::Preek](https://github.com/joenas/guard-preek))

### Find out more:

* [Stack Overflow](http://stackoverflow.com/questions/tagged/reek)
* [RDoc](http://rdoc.info/projects/troessner/reek)
