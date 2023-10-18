# Uncommunicative Parameter Name

## Introduction

An _Uncommunicative Parameter Name_ is a parameter name that doesn't
communicate its intent well enough. This code smell is a case of
[Uncommunicative Name](Uncommunicative-Name.md).

## Current Support in Reek

_Uncommunicative Parameter Name_ checks for:

* single-character names
* any name ending with a number
* camelCaseParameterNames

## Configuration

Reek's _Uncommunicative Parameter Name_ detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option   | Value       | Effect  |
| ---------|-------------|---------|
| `reject` | array of strings | The set of names that Reek uses to check for bad names. Defaults to single-letter names, names containing an uppercase letter, names with a number at the end and '_'. |
| `accept` | array of strings | The set of names that Reek will accept (and not report) even if they match one of the `reject` expressions. |


An example configuration could look like this:

```yaml
---
UncommunicativeParameterName:
  accept:
    - x
    - arg1
  reject:
    - foobar
```

Reek will convert whatever you give it as a string to the corresponding regex, so "foobar" from above will be converted to /foobar/ internally. 

Applying a configuration to a source file like this:

```ruby
def omg(x); x; end # Should not be reported
def omg(arg1); arg1; end # Should not be reported
def omg(foobar); foobar; end # Should be reported
```

Reek would report:

```
smelly.rb -- 1 warning:
  [3]:UncommunicativeParameterName: omg has the parameter name 'foobar'
```

## Advanced configuration

Sometimes just strings are not enough for configuration. E.g. consider this code sample:

```ruby
class Klass
  def my_method(foo, foobar); end
end
```

and now imagine that you want to reject the name "foo" but not "foobar". This wouldn't be possible with just using strings.
For this reason Reek has a special syntax that allows you to use regexes by using a forward slash at the beginning and the end of the string.
Everything within the forward slashes will be loaded as a regex.

A possible configuration that allows "foobar" but rejects "foo" could look like this:

```yaml
---
UncommunicativeParameterName:
  reject:
    - "/^foo$/"
```

## Reek 4

In Reek 4 you could also pass regexes to `accept` or `reject`, meaning this was perfectly valid as well:

```yaml
UncommunicativeParameterName:
  accept:
    - !ruby/regexp /foobar/
```

Support for this has been scrapped with Reek 5 to make the Reek configuration more yaml standard compliant.
You can still pass in regexes, you just have to wrap them into a string. Please see "Advanced configuration" above.
