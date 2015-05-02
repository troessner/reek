# Attribute

## Introduction

A class that publishes a getter or setter for an instance variable invites client classes to become too intimate with its inner workings, and in particular with its representation of state.

## Example

Given:

```Ruby
class Klass
  attr_accessor :dummy
end
```

`reek` would emit the following warning:

```
reek test.rb

test.rb -- 1 warning:
  [2]:Klass declares the attribute dummy (Attribute)
```

## Support in Reek

Right now this smell is disabled by default since it is highly subjective.

When this detector is enabled it raises a warning for every `attr`, `attr_reader`, `attr_writer` and `attr_accessor` -- including those that are private.

## Configuration

If you want to enable it you can do so by placing

```yaml
Attribute:
  enabled: true
```

in your reek configuration file.

`Attribute` supports only the [Basic Smell Options](Basic-Smell-Options.md).
