## Introduction

_Too Many Methods_ is a case of [Large Class](Large-Class.md).

## Example

Given this configuration

```yaml
TooManyMethods:
  max_methods: 3
```

and this code:

```ruby
class Smelly
  def one; end
  def two; end
  def three; end
  def four; end
end
```

Reek would emit the following warning:

```
test.rb -- 1 warning:
  [1]:TooManyMethods: Smelly has at least 4 methods
```
## Current Support in Reek

Reek counts all the methods it can find in a class &mdash; instance *and* class
methods. So given `max_methods` from above is 4, this:

```ruby
class Smelly
  class << self
    def one; end
    def two; end
  end

  def three; end
  def four; end
end
```

would cause Reek to emit the same warning as in the example above.

## Configuration

Reek's _Too Many Methods_ detector offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option                              | Value   | Effect  |
| ------------------------------------|---------|---------|
| `max_methods`                       | integer | The maximum number of methods that are permitted, regardless of their visibility. Defaults to 15 |
| `max_public_methods`                | integer | The maximum number of public methods that are permitted. Not checked by default |
| `max_protected_methods`             | integer | The maximum number of protected methods that are permitted. Not checked by default |
| `max_private_methods`               | integer | The maximum number of private methods that are permitted. Not checked by default |
| `max_private_and_protected_methods` | integer | The maximum number of private and protected methods taken together that are permitted. Not checked by default |
| `ignore_public_methods`             | Boolean | Do not count public methods at all. Defaults to `false` |
| `ignore_protected_methods`          | Boolean | Do not count protected methods at all. Defaults to `false` |
| `ignore_private_methods`            | Boolean | Do not count private methods at all. Defaults to `false` |

Every `max_*` option is a check of its own, so a class can trigger more than one
warning at a time:

```yaml
---
detectors:
  TooManyMethods:
    max_methods: 20
    max_public_methods: 5
    max_private_methods: 10
```

A class with 6 public and 11 private methods would then be reported twice:

```
test.rb -- 2 warnings:
  [1]:TooManyMethods: Smelly has at least 11 private methods
  [1]:TooManyMethods: Smelly has at least 6 public methods
```

Unlike `max_methods`, the visibility specific thresholds have no default at all,
so simply leave one out to not have it checked. Listing one without a value is a
configuration error, the same as for every other option.

Note that a threshold you switched on in your configuration file cannot be
switched off again for a single class with a
[code comment](Smell-Suppression.md); a code comment can only give it a
different value.

### Ignoring a visibility

The `ignore_*` options take methods of that visibility out of *every* count this
detector performs, which is how you restrict the smell to a single visibility.
To only ever be warned about public methods:

```yaml
---
detectors:
  TooManyMethods:
    max_methods: 5
    ignore_private_methods: true
    ignore_protected_methods: true
```

Note that ignoring a visibility also switches off its own threshold, so
combining `ignore_private_methods: true` with `max_private_methods` reports
nothing, and `max_private_and_protected_methods` falls back to counting
protected methods only.

### Visibility and class methods

Visibility is tracked per method, including for the methods in a `class << self`
body, so `private` inside a singleton class is counted as private:

```ruby
class Smelly
  class << self
    def public_class_method; end

    private

    def private_class_method; end
  end
end
```

Methods defined as `def self.some_method` are not counted by this detector at
all, and neither are attributes created with `attr_reader` and friends.

Methods below a bare `module_function` are treated as their own visibility
rather than as private ones, so they count towards `max_methods` but towards
none of the visibility specific options.
