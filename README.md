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

### Integration

Basically there are two ways to use reek in your project except for the obvious static code analysis:

(1) Use Reek's [Rake Task](https://github.com/troessner/reek/wiki/Rake-Task) to easily add Reek to your Rakefile

(2) Add Reek's custom matcher to your Rspec examples like this:

```Ruby
require 'rubygems'
require 'spec'
require 'reek'
require 'reek/spec'
require 'reek/spec'

include Reek::Spec

my_precious_code = 'class C; def m; end; end'
my_precious_code.should_not reek # Well, it does.
```

## Contributing

* Fork the repo
* Create a feature branch
* Make sure the tests pass (see below)
* Submit a pull request

### Running the tests

Either just `rake` to run all or, if you want to be specific:

```bash
spec spec/your/file        # Runs all tests
spec spec/your/file -l 23  # Runs test in line 23
spec spec/your/file -u     # Runs all tests stopping at the breakpoints you have set before with `debugger`
```

### Tool Integration

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

