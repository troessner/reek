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
| `reject` | array of regular expressions or strings | The set of patterns / names that Reek uses to check for bad names. Defaults to `[/^.$/, /[0-9]$/, /[A-Z]/, /^_/]. |
| `accept` | array of regular expressions or strings | The set of patterns / names that Reek will accept (and not report) even if they match one of the `reject` expressions. |


An example configuration could look like this:

```Yaml
---
UncommunicativeParameterName:
  accept:
    - !ruby/regexp /x/
    - arg1
  reject:
    - !ruby/regexp /foobar/
```

Applying a configuration to a source file like this:

```Ruby
def omg(x); x; end # Should not be reported
def omg(arg1); arg1; end # Should not be reported
def omg(foobar); foobar; end # Should be reported
```

Reek would report:

```
smelly.rb -- 1 warning:
  [3]:UncommunicativeParameterName: omg has the parameter name 'foobar' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Parameter-Name.md]
```
