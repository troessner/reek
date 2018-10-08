![reek logo](logo/reek.text.png)

# Code smell detector for Ruby

**Table of Contents**

- [Overview](#overview)
- [Quickstart](#quickstart)
- [Example](#example)
- [Supported Ruby versions](#supported-ruby-versions)
- [Fixing Smell Warnings](#fixing-smell-warnings)
- [Sources](#sources)
- [Code smells](#code-smells)
- [Configuration](#configuration)
  - [Command-line interface](#command-line-interface)
  - [Configuration file](#configuration-file)
    - [Configuration loading](#configuration-loading)
    - [Configuration options](#configuration-options)
  - [Generating a 'todo' list](#generating-a-todo-list)
  - [Beware of multiple configuration files](#beware-of-multiple-configuration-files)
  - [Source code comments](#source-code-comments)
- [Usage](#usage)
- [Developing Reek / Contributing](#developing-reek--contributing)
- [Output formats](#output-formats)
- [Working with Rails](#working-with-rails)
- [Integrations](#integrations)
  - [Editor integrations](#editor-integrations)
  - [Projects that use or support us](#projects-that-use-or-support-us)
  - [Misc](#misc)
- [Brothers and sisters](#brothers-and-sisters)
- [Contributors](#contributors)
- [Additional resources](#additional-resources)
  - [Miscellaneous](#miscellaneous)
  - [More information](#more-information)

## Overview

* [![Build Status](https://secure.travis-ci.org/troessner/reek.svg?branch=master)](https://travis-ci.org/troessner/reek?branch=master)
* [![Gem Version](https://badge.fury.io/rb/reek.svg)](https://badge.fury.io/rb/reek)
* ![](http://img.shields.io/github/tag/troessner/reek.svg)
* ![](http://img.shields.io/badge/license-MIT-brightgreen.svg)
* [![Inline docs](https://inch-ci.org/github/troessner/reek.png)](https://inch-ci.org/github/troessner/reek)
* [![Code Climate](https://codeclimate.com/github/troessner/reek/badges/gpa.svg)](https://codeclimate.com/github/troessner/reek)
* [![codebeat](https://codebeat.co/badges/42fed4ff-3e55-4aed-8ecc-409b4aa539b3)](https://codebeat.co/projects/github-com-troessner-reek)
* ![](http://ruby-gem-downloads-badge.herokuapp.com/reek?type=total)
* ![](http://ruby-gem-downloads-badge.herokuapp.com/reek?label=downloads-current-version)

## Reek 5 is out!

Reek 5 is out and with it a bunch of breaking changes. If you're a new user you can just
continue with the quickstart below. If you're a Reek 4 user and would like to upgrade to 5, don't
worry, this shouldn't take you more than 10 minutes. Check out our [Upgrade Guide](docs/Reek-4-to-Reek-5-migration.md).

## Quickstart

Reek is a tool that examines Ruby classes, modules and methods and reports any
[Code Smells](docs/Code-Smells.md) it finds.

For an excellent introduction to
[Code Smells](docs/Code-Smells.md) and Reek check out [this blog post](https://blog.codeship.com/how-to-find-ruby-code-smells-with-reek/)
or [that one](https://troessner.svbtle.com/the-latest-and-greatest-additions-to-reek). There is also [this talk](https://www.youtube.com/watch?v=pazYe7WRWRU) from [RubyConfBY](http://rubyconference.by/) (there is also a [slide deck](http://talks.chastell.net/rubyconf-by-lt-2016/) if you prefer that).

Install it via rubygems:

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
# Smelly class
class Smelly
  # This will reek of UncommunicativeMethodName
  def x
    y = 10 # This will reek of UncommunicativeVariableName
  end
end
```

Reek will report the following code smells in this file:

```
$ reek --no-documentation demo.rb
Inspecting 1 file(s):
S

demo.rb -- 2 warnings:
  [4]:UncommunicativeMethodName: Smelly#x has the name 'x'
  [5]:UncommunicativeVariableName: Smelly#x has the variable name 'y'
```

## Supported Ruby versions

Reek is officially supported for the following CRuby versions:

  - 2.3
  - 2.4
  - 2.5

Other Ruby implementations (like Rubinius or JRuby) are not officially supported but should work as well.

## Fixing Smell Warnings

Reek focuses on high-level code smells, so we can't tell you how to fix warnings in
a generic fashion; this is and will always be completely dependent on your domain
language and business logic.

That said, an example might help you get going. Have a look at this sample of a
Ruby on Rails model (be aware that this is truncated, not working code):

```Ruby
class ShoppingCart < ActiveRecord::Base
  has_many :items

  def gross_price
    items.sum { |item| item.net + item.tax }
  end
end

class Item < ActiveRecord::Base
  belongs_to :shopping_cart
end
```

Running Reek on this file like this:

```
reek app/models/shopping_cart.rb
```

would report:

```
  [5, 5]:ShoppingCart#gross_price refers to item more than self (FeatureEnvy)
```

Fixing this is pretty straightforward. Put the gross price calculation for a single item
where it belongs, which would be the `Item` class:

```Ruby
class ShoppingCart < ActiveRecord::Base
  has_many :items

  def gross_price
    items.sum { |item| item.gross_price }
  end
end

class Item < ActiveRecord::Base
  belongs_to :shopping_cart

  def gross_price
    net + tax
  end
end
```

The [Code Smells](docs/Code-Smells.md) docs may give you further hints - be sure to check out
those first when you have a warning that you don't know how to deal with.

## Sources

There are multiple ways you can have Reek work on sources, the most common one just being

```Bash
reek lib/
```

If you don't pass any source arguments to Reek it just takes the current working directory as source.

So

```Bash
reek
```

is the exact same thing as being explicit:

```Bash
reek .
```

Additionally you can pipe code to Reek like this:

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

Reek currently includes checks for some aspects of
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
for up to date details of exactly what Reek will check in your code.

**Special configuration for controversial detectors:**

[Unused Private Method](docs/Unused-Private-Method.md) is disabled by default
because it is [kind of controversial](https://github.com/troessner/reek/issues/844) which means
you have to explicitly activate it in your configuration via

```Yaml
UnusedPrivateMethod:
  enabled: true
```

[Utility Function](docs/Utility-Function.md) is a [controversial detector](https://github.com/troessner/reek/issues/681)
as well that can turn out to be really unforgiving.
As a consequence, we made it possible to disable it for non-public methods like this:

```Yaml
---
UtilityFunction:
  public_methods_only: true
```

## Configuration

### Command-line interface

For a basic overview, run

```Ruby
reek --help
```

For a summary of those CLI options see [Command-Line Options](docs/Command-Line-Options.md).

### Configuration file

#### Configuration loading

Configuring Reek via a configuration file is by far the most powerful way.
Reek expects this filename to be `.reek.yml` but you can override this via the CLI `-c` switch (see below).

There are three ways of passing Reek the configuration file:

1. Using the CLI `-c` switch (see [_Command-line interface_](#command-line-interface) above)
2. Having the configuration file either in your current working directory or in a parent directory (more on that later)
3. Having the configuration file in your home directory

The order in which Reek tries to find such a configuration
file is exactly the above: first it checks if we have given
it a configuration file explicitly via CLI; then it checks
the current working directory for a file and if it can't
find one, it traverses up the directories until it hits the
root directory; lastly, it checks your home directory.

As soon as Reek detects a configuration file it stops searching
immediately, meaning that from Reek's point of view there exists
exactly one configuration file and one configuration, regardless
of how many `*.reek` files you might have on your filesystem.

#### Configuration options

We put a lot of effort into making Reek's configuration as self explanatory as possible so the
best way to understand it is by looking at a simple
example (e.g. `.reek.yml` in your project directory):

```yaml
---

### Generic smell configuration

detectors:
  # You can disable smells completely
  IrresponsibleModule:
    enabled: false
  
  # You can use filters to silence Reek warnings.
  # Either because you simply disagree with Reek (we are not the police) or
  # because you want to fix this at a later point in time.
  NestedIterators:
    exclude:
      - "MyWorker#self.class_method" # should be refactored
      - "AnotherWorker#instance_method" # should be refactored as well
  
  # A lot of smells allow fine tuning their configuration. You can look up all available options
  # in the corresponding smell documentation in /docs. In most cases you probably can just go
  # with the defaults as documented in defaults.reek.yml.
  DataClump:
    max_copies: 3
    min_clump_size: 3

### Directory specific configuration

# You can configure smells on a per-directory base.
# E.g. the classic Rails case: controllers smell of NestedIterators (see /docs/Nested-Iterators.md) and
# helpers smell of UtilityFunction (see docs/Utility-Function.md)
# Note that we only allow configuration on a directory level, not a file level, so all paths have to point to directories.
directories:
  "web_app/app/controllers":
    NestedIterators:
      enabled: false
  "web_app/app/helpers":
    UtilityFunction:
      enabled: false

### Excluding directories

# Directories and files below will not be scanned at all
exclude_paths:
  - lib/legacy
  - lib/rake/legacy_tasks
  - lib/smelly.rb  
```

As you see above, Reek's configuration consists of 3 different sections denoted by 3 different keys:

* detectors
* directories
* exclude_paths

Whatever you add to your configuration should be scoped under one of those keys.

If you have a directory directive for which a default directive exists, the more specific
one (which is the directory directive) will take precedence.

This configuration for instance:

```yaml
---
detectors:
  IrresponsibleModule:
    enabled: false
  
  TooManyStatements:
    max_statements: 5
```

translates to:

* IrresponsibleModule is disabled everywhere
* TooManyStatements#max_statements is 10 in "app/controllers"
* TooManyStatements#max_statements is 5 everywhere else

Every smell detector supports our [Basic Smell Options](docs/Basic-Smell-Options.md). As you can see above,
certain smell types offer a configuration that goes beyond that of the basic smell options, for instance
[Data Clump](docs/Data-Clump.md).
All options that go beyond the [Basic Smell Options](docs/Basic-Smell-Options.md)
are documented in the corresponding smell type /docs page (if you want to get a quick overview over all possible
configurations you can also check out [the `defaults.reek.yml` file in this repository](docs/defaults.reek.yml).

Note that you do not need a configuration file at all.
If you're fine with all the [defaults.reek.yml](docs/defaults.reek.yml) we set you can skip this completely.

Don't worry about introducing a mistake in your configuration file that might go unnoticed - Reek uses a
schema to validate your configuration against on start up and will faily loudly in case you
misspelled an option or used the wrong data type for a value like this:

```
Error: We found some problems with your configuration file: [/detectors/DetectorWithTypo] key 'DetectorWithTypo:' is undefined.
```

Reek takes one configuration file and one configuration file only with `.reek.yml` being the default name.

In case you have to have one or more configuration files in the directory (e.g. you're
toying around with different, mutually exclusive settings) you need to tell Reek
explicitly which file to use via `reek -c config.reek`.

### Source code comments

In case you need to suppress a smell warning and you can't or don't want to
use configuration files for whatever reasons you can also use special
source code comments like this:

```Ruby
# This method smells of :reek:NestedIterators
def smelly_method foo
  foo.each {|bar| bar.each {|baz| baz.qux}}
end
```

You can even pass in smell specific configuration settings:

```Ruby
# :reek:NestedIterators { max_allowed_nesting: 2 }
def smelly_method foo
  foo.each {|bar| bar.each {|baz| baz.qux}}
end
```

This is an incredibly powerful feature and further explained under [Smell Suppresion](docs/Smell-Suppression.md).

#### Debugging trouble with the configuration

With Reeks dynamic mechanism of finding a configuration file you might run into a situation where you are not
100% sure what configuration file Reek is using. E.g. you have a project specific configuration file in your
project root and also another Reek configuration in your HOME directory that you use for all your other projects
and for whatever reasons Reek seems to be using another configuration file than the one you assumed it would.

In this case you can pass the flag `--show-configuration-path` to Reek which will cause Reek to output the path
to the configuration file it is using.

### Generating a 'todo' list

Integrating tools like Reek into an existing larger codebase can be daunting when you have to fix
possibly hundreds or thousands of smell warnings first.
Sure you could manually disable smell warnings like shown above but depending on the size of your
codebase this might not be an option.
Fortunately Reek provides a 'todo' flag which you can use to generate a configuration that will
suppress all smell warnings for the current codebase:

```Bash
reek --todo lib/
```

This will create the file '.reek.yml' in your current working directory.

You can then use this as your configuration - since your working directory
probably is your project root in most cases you don't have to tell Reek
explicitly to use '.reek.yml' because Reek will automatically pick it up
and use it as configuration file. See [Configuration Loading](#configuration-loading) above.

If for whatever reasons you decide to put '.reek.yml' somewhere else where
Reek won't pick it up automatically you need to tell Reek explicitly to do so
via:

```Bash
reek -c whatever/.reek.yml lib/
```

It's important to understand that the number one use case of the `--todo` flag
is to be run once at the beginning of the introduction of Reek to ease the transition.
If you find yourself wanting to re-run Reek with the `--todo` flag in order to silence a lot of new warnings
you're defeating the purpose of both the `--todo` flag and of Reek itself.

As a consequence, running Reek with the `--todo` flag again will not overwrite an existing '.reek.yml'
and instead abort execution. It also will not take **any** other configuration file you might have into account.

This means that when you run

```Bash
reek -c other_configuration.reek --todo lib/
```

`other_configuration.reek` will simply be ignored.

Of course you can always just delete the existing .reek.yml file and then run Reek with the `--todo` flag
but keep in mind that this is not the intended use case of this feature.

## Usage

Besides the obvious

```Bash
reek [options] [dir_or_source_file]*
```

there are quite a few other ways how to use Reek in your projects:

* Use Reek's [Rake task](docs/Rake-Task.md) to automate detecting code smells
* Add Reek's custom matcher to your [RSpec examples](docs/RSpec-matchers.md)
* Include Reek using the [Developer API](docs/API.md)

## Developing Reek / Contributing

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

This will run the tests (RSpec and Cucumber), RuboCop and Reek itself.

Another useful Rake task is the `console` task. This will throw you right into an environment where you can play around with Reeks modules and classes:

```
bundle exec rake console

[3] pry(main)> require_relative 'lib/reek/examiner'
=> true
[4] pry(main)> Reek::Examiner
=> Reek::Examiner
```

You can also use Pry while running the tests by adding the following at the
point where you want to start debugging:

```Ruby
require 'pry'
binding.pry
```

Have a look at our [Developer API](docs/API.md) for more inspiration.

From then on you should check out:

* [How Reek works internally](docs/How-reek-works-internally.md)
* [the contributing guide](CONTRIBUTING.md)

If you don't feel like getting your hands dirty with code there are still other ways you can help us:

* Open up an [issue](https://github.com/troessner/reek/issues) and report bugs
* Suggest other improvements like additional smells for instance

### Running Code Climate locally

If you run into Code Climate issues (e.g., go over code duplication
threshold) you might want to be able to run Code Climate against
the Reek codebase locally. To do this, you need to do the following:

* [install Docker CE](https://docs.docker.com/engine/installation/)
* [install Code Climate CLI](https://github.com/codeclimate/codeclimate#installation)
* `gem install codeclimate`
* `codeclimate engines:install`

Now you can run various Code Climate engines,
e.g., `codeclimate analyze -e duplication`

## Output formats

Reek supports 5 output formats:

* plain text (default)
* HTML (`--format html`)
* YAML (`--format yaml`, see also [YAML Reports](docs/YAML-Reports.md))
* JSON (`--format json`)
* XML  (`--format xml`)

## Working with Rails

Making Reek "Rails"-friendly is fairly simple since we support directory specific configurations (`directory directives` in Reek talk).
Just add this to your configuration file:

```Yaml
directories:
  "app/controllers":
    IrresponsibleModule:
      enabled: false
    NestedIterators:
      max_allowed_nesting: 2
    UnusedPrivateMethod:
      enabled: false
    InstanceVariableAssumption:
      enabled: false
  "app/helpers":
    IrresponsibleModule:
      enabled: false
    UtilityFunction:
      enabled: false
  "app/mailers":
    InstanceVariableAssumption:
      enabled: false
  "app/models":
    InstanceVariableAssumption:
      enabled: false
```

Be careful though, Reek does not merge your configuration entries, so if you already have a directory directive for "app/controllers" or "app/helpers" you need to update those directives instead of copying the above YAML sample into your configuration file.

## Integrations

### Editor integrations

* [Vim plugin](https://github.com/rainerborene/vim-reek)
* [TextMate Bundle](https://github.com/peeyush1234/reek.tmbundle)
* [Atom plugin](https://atom.io/packages/linter-reek)
* [SublimeLinter plugin](https://packagecontrol.io/packages/SublimeLinter-contrib-reek)
* [VS Code plugin](https://github.com/rubyide/vscode-ruby)
* [Emacs plugin](https://github.com/hanmoi-choi/reek-emacs)

### Projects that use or support us

* [overcommit](https://github.com/brigade/overcommit) - a Git commit hook manager with support for
  Reek
* [ruby-critic](https://github.com/whitesmith/rubycritic) - gem that wraps around static analysis gems such as Reek, [flay](https://github.com/seattlerb/flay) and [flog](https://github.com/seattlerb/flog)
* [pronto-reek](https://github.com/mmozuras/pronto-reek) - Reek integration for [pronto](https://github.com/mmozuras/pronto)

### Misc

* [Colorful output for Reek](https://github.com/joenas/preek)
  (also with [Guard::Preek](https://github.com/joenas/guard-preek))

## Brothers and sisters

A non-exhaustive list of other static code analyzers you might want to look into:

* [debride](https://github.com/seattlerb/debride) - analyze code for potentially uncalled / dead methods
* [flay](https://github.com/seattlerb/flay) - analyze code for structural similarities
* [flog](https://github.com/seattlerb/flog) - reports the most tortured code in an easy to read pain
report
* [SandiMeter](https://github.com/makaroni4/sandi_meter) - checking your Ruby code for Sandi Metz' four rules
* [ruby-lint](https://github.com/YorickPeterse/ruby-lint) - static code analysis tool
* [Fasterer](https://github.com/DamirSvrtan/fasterer) - Fasterer will suggest some speed improvements based on [fast-ruby](https://github.com/JuanitoFatas/fast-ruby)

## Contributors

The Reek core team consists of:

* [Matijs van Zuijlen](https://github.com/mvz)
* [Piotr Szotkowski](https://github.com/chastell)
* [Waldyr Souza](https://github.com/waldyr)
* [Timo Rößner](https://github.com/troessner)

The original author of Reek is [Kevin Rutherford](https://github.com/kevinrutherford).

The author of Reek’s logo is [Sonja Heinen](http://yippee.io).

Notable contributions came from:

* [Andrew Wagner](https://github.com/arwagner)
* [Gilles Leblanc](https://github.com/gilles-leblanc)
* [Emil Rehnberg](https://github.com/EmilRehnberg)

## Additional resources

### Miscellaneous

* [Reek Driven Development](docs/Reek-Driven-Development.md)
* [Versioning policy](docs/Versioning-Policy.md)

### More information

* [Stack Overflow](https://stackoverflow.com/questions/tagged/reek)
* [RubyDoc.info](http://www.rubydoc.info/gems/reek)
