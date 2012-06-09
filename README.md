# Reek -- code smell detection for Ruby

[![Build Status](https://secure.travis-ci.org/troessner/reek.png?branch=master)](http://travis-ci.org/troessner/reek?branch=master)

Reek is a tool that examines Ruby classes, modules and methods and
reports any code smells it finds. Install it like this:

```bash
$ gem install reek
```

and run it like this:

```bash
$ reek [options] [dir_or_source_file]*
```

For a full list of command-line options see the Reek
wiki[http://wiki.github.com/troessner/reek/command-line-options]
or run

```bash
$ reek --help
```

## Example

Imagine a source file <tt>demo.rb</tt> containing:

```ruby
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

```bash
$ reek demo.rb
spec/samples/demo/demo.rb -- 6 warnings:
  Dirty has no descriptive comment (IrresponsibleModule)
  Dirty#awful has 4 parameters (LongParameterList)
  Dirty#awful has boolean parameter 'log' (ControlCouple)
  Dirty#awful has the parameter name 'x' (UncommunicativeName)
  Dirty#awful has the parameter name 'y' (UncommunicativeName)
  Dirty#awful has the variable name 'w' (UncommunicativeName)
```

## Features

Reek currently includes checks for some aspects of Control Couple,
Data Clump, Feature Envy, Large Class, Long Method, Long Parameter List,
Simulated Polymorphism, Uncommunicative Name and more.
See the [Reek wiki](http://wiki.github.com/troessner/reek/code-smells)
for up to date details of exactly what Reek will check in your code.

### Tool Integration

Reek integrates with many of your favourite tools:

* `require 'reek/rake/task'` to easily add Reek to your Rakefile
* `require 'reek/spec'` to add the `should_not reek` custom matcher to your Rspec examples
* Reek is compatible with Ruby 1.8.6, 1.8.7, 1.9.2 and 1.9.3

### Dependencies

Reek makes use of the following other gems:

* ruby_parser
* sexp_processor
* ruby2ruby

Learn More
----------

Find out more about Reek from any of the following sources:

* Browse the Reek documentation at [http://wiki.github.com/troessner/reek](http://wiki.github.com/troessner/reek)
* Browse the code or install the latest development version from [http://github.com/troessner/reek/tree](http://github.com/troessner/reek/tree)
* Read the code API at [http://rdoc.info/projects/troessner/reek](http://rdoc.info/projects/troessner/reek)

