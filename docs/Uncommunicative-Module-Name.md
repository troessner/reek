# Uncommunicative Module Name

## Introduction

An _Uncommunicative Module Name_ is a module name that doesn't communicate its
intent well enough. This code smell is a case of
[Uncommunicative Name](Uncommunicative-Name.md).

## Current Support in Reek

_Uncommunicative Module Name_ checks for:

* single-character names
* any name ending with a number

## Configuration

Reek's _Uncommunicative Module Name_ detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `reject` | array of strings | The set of names that Reek uses to check for bad names. Defaults to single-letter names and names ending with a number. |
| `accept` | array or strings | The set of names that Reek will accept (and not report) even if they match one of the `reject` expressions. Empty by default.|

An example configuration could look like this:

```yaml
---
UncommunicativeModuleName:
  accept:
    - lassy
    - Util
  reject:
    - Helper
```

Reek will convert whatever you give it as a string to the corresponding regex, so "Helper" from above will be converted to /Helper/ internally. 

Applying a configuration to a source file like this:

```ruby
class Classy1; end # Should not be reported
class Util; end # Should not be reported
class BaseHelper; end # Should be reported
```

Reek would report:

```
smelly.rb -- 1 warning:
  [3]:UncommunicativeModuleName: BaseHelper has the name 'BaseHelper'
```

## Advanced configuration

Sometimes just strings are not enough for configuration. E.g. consider this code sample:

```ruby
class Klassy
  # ...
end

class KlassyModule
  # ...
end
```

and now imagine that you want to reject the name "Klassy" but not "KlassyModule". This wouldn't be possible with just using strings.
For this reason Reek has a special syntax that allows you to use regexes by using a forward slash at the beginning and the end of the string.
Everything within the forward slashes will be loaded as a regex.

A possible configuration that allows "KlassyModule" but rejects "Klassy" could look like this:

```yaml
---
UncommunicativeModuleName:
  reject:
    - "/^Klassy$/"
```

## Reek 4

In Reek 4 you could also pass regexes to `accept` or `reject`, meaning this was perfectly valid as well:

```yaml
UncommunicativeModuleName:
  accept:
    - !ruby/regexp /foobar/
```

Support for this has been scrapped with Reek 5 to make the Reek configuration more yaml standard compliant.
You can still pass in regexes, you just have to wrap them into a string. Please see "Advanced configuration" above.
