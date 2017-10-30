## Introduction

Classes should use their private methods. Otherwise this is dead
code which is confusing and bad for maintenance.

The _Unused Private Method_ detector reports unused private instance
methods and instance methods only - class methods are ignored.

## Example

Given:

```Ruby
class Car
  private
  def drive; end
  def start; end
end
```

Reek would emit the following warning:

```
2 warnings:
  [3]:Car has the unused private instance method `drive` (UnusedPrivateMethod)
  [4]:Car has the unused private instance method `start` (UnusedPrivateMethod)
```

## Configuration

_Unused Private Method_ offers the [Basic Smell Options](Basic-Smell-Options.md).

Private methods that are called via dynamic dispatch
will trigger a false alarm since detecting something like this is far out of
scope for Reek. In this case you can disable this detector via the `exclude`
configuration option (which is part of the [Basic Smell Options](Basic-Smell-Options.md))
for instance like this (an example from Reek's own codebase):

```Ruby
# :reek:UnusedPrivateMethod { exclude: [ !ruby/regexp /process_/ ] }
class ContextBuilder
  def process_begin
    # ....
  end
end
```

Note that disabling this detector via comment works on a class scope, not
a method scope (like you can see above).

Another simple example would be:

```Ruby
class Alfa
  private
  def bravo
  end
end
```

This would report:

>>
ruby.rb -- 1 warning:
  [3]:UnusedPrivateMethod: Alfa has the unused private instance method 'bravo'

If you want to suppress this warning you can do this via source comment like this:

```Ruby
# :reek:UnusedPrivateMethod: { exclude: bravo }
class Alfa
  private
  def bravo
  end
end
```

## Known limitations

* Method calls via dynamic dispatch (e.g. via `send`) is something Reek (or any other
  static tool for that matter) cannot detect.
* Method calls via callback like [Rails filters](http://guides.rubyonrails.org/action_controller_overview.html#filters)
  will trigger this as well, e.g.:

```Ruby
  class BankController < ActionController::Base
    before_filter :audit

    private
    def audit
      # ....
    end
  end
```
* Reek works on a per-file base. This means that using something like the [template pattern](https://en.wikipedia.org/wiki/Template_method_pattern)
  with private methods will trigger this detector.
  We do believe though that using private methods to fill out a template in a
  superclass is not a good idea in general so this probably isn't really a problem
  but still worth mentioning it.


