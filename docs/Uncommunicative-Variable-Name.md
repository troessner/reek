# Uncommunicative Variable Name

## Introduction

An _Uncommunicative Variable Name_ is a variable name that doesn't communicate
its intent well enough. This code smell is a case of
[Uncommunicative Name](Uncommunicative-Name.md).

## Current Support in Reek

_Uncommunicative Variable Name_ checks for:

* single-character names
* any name ending with a number
* camelCaseVariableNames

## Configuration

Reek's _Uncommunicative Variable Name_ detector supports the
[Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `reject` | array of strings | The set of names that Reek uses to check for bad names. Defaults to single-letter names, names ending with a number or names containing upper case letters. |
| `accept` | array of strings | Names that will be accepted (not reported) even if they match one of the `reject` expressions. Defaults to `_`.|

An example configuration could look like this:

```yaml
---
UncommunicativeVariableName:
  accept:
    - x
    - var1
  reject:
    - helper
    - foobar
```

Reek will convert whatever you give it as a string to the corresponding regex, so "foobar" from above will be converted to /foobar/ internally. 

Applying a configuration to a source file like this:

```ruby
def omg
  x = 5 # Should not be reported
  var1 = true # Should not be reported
  helper = 42 # Should be reported
  foobar = false # Should be reported
end
```

Reek would report:

```
smelly.rb -- 2 warnings:
  [5]:UncommunicativeVariableName: omg has the variable name 'foobar' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
  [4]:UncommunicativeVariableName: omg has the variable name 'helper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Variable-Name.md]
```

## Advanced configuration

Sometimes just strings are not enough for configuration. E.g. consider this code sample:

```ruby
def omg
  foo = 42
  foobar = 4242
end
```

and now imagine that you want to reject the name "foo" but not "foobar". This wouldn't be possible with just using strings.
For this reason Reek has a special syntax that allows you to use regexes by using a forward slash at the beginning and the end of the string.
Everything within the forward slashes will be loaded as a regex.

A possible configuration that allows "foobar" but rejects "foo" could look like this:

```yaml
---
UncommunicativeVariableName:
  reject:
    - "/^foo$/"
```

## Reek 4

In Reek 4 you could also pass regexes to `accept` or `reject`, meaning this was perfectly valid as well:

```yaml
UncommunicativeVariableName:
  accept:
    - !ruby/regexp /write/
```

Support for this has been scrapped with Reek 5 to make the Reek configuration more yaml standard compliant.
You can still pass in regexes, you just have to wrap them into a string. Please see "Advanced configuration" above.
