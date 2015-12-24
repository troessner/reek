## Introduction

Classes should use their private methods. Otherwise this is dead
code which is confusing and bad for maintenance.

## Example

Given:

```Ruby
class Car
  class << self
    private
    def start_the_engine; end
  end
  private
  def drive; end
end
```

`Reek` would emit the following warning:

```
2 warnings:
  [3]:Car has the unused private class method `start_the_engine` (UnusedPrivateMethod)
  [4]:Car has the unused private instance method `drive` (UnusedPrivateMethod)
```

As you can see above, `Unused Private Method` does differentiate between class
and instance methods.

Private methods that are called via dynamic dispatch
will trigger a false alarm since detecting something like this is far out of
scope for `Reek`. In this case you can disable this detector via the `exclude`
configuration option (which is part of the [Basic Smell Options](Basic-Smell-Options.md))
for instance like this (an example from `Reek's` own codebase):

```Ruby
# :reek:UnusedPrivateMethod: { exclude: [ !ruby/regexp /process_/ ] }
class ContextBuilder
  def process_begin
    # ....
  end
end
```

## Configuration

`Unused Private Method` offers the [Basic Smell Options](Basic-Smell-Options.md).
