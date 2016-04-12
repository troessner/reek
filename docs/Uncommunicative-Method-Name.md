# Uncommunicative Method Name

## Introduction

An _Uncommunicative Method Name_ is a method name that doesn't communicate its
intent well enough. This code smell is a case of
[Uncommunicative Name](Uncommunicative-Name.md).

## Current Support in Reek

_Uncommunicative Method Name_ checks for:

* single-character names
* any name ending with a number
* camelCaseMethodNames

## Configuration

Reek's _Uncommunicative Method Name_ detector supports the
[Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `reject` | array of regular expressions or strings | The set of patterns / names that Reek uses to check for bad names. Defaults to `[/^[a-z]$/, /[0-9]$/, /[A-Z]/]`. |
| `accept` | array of regular expressions or strings | The set of patterns / names that Reek will accept (and not report) even if they match one of the `reject` expressions. |

An example configuration could look like this:

```Yaml
---
UncommunicativeMethodName:
  accept:
    - !ruby/regexp /x/
    - meth1
  reject:
    - !ruby/regexp /helper/
    - foobar
```

Applying a configuration to a source file like this:

```Ruby
def x; end # Should not be reported
def meth1; end # Should not be reported
def foobar; end # Should be reported
def awesome_helper; end # Should be reported
```

Reek would report:

```
smelly.rb -- 2 warnings:
  [4]:UncommunicativeMethodName: awesome_helper has the name 'awesome_helper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
  [3]:UncommunicativeMethodName: foobar has the name 'foobar' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md]
```
