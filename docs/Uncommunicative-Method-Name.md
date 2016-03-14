# Uncommunicative Method Name

## Introduction

An `Uncommunicative Method Name` is a method name that doesn't communicate its intent well enough.

Poor names make it hard for the reader to build a mental picture of what's going on in the code. They can also be mis-interpreted; and they hurt the flow of reading, because the reader must slow down to interpret the names.

## Current Support in Reek

`Uncommunicative Method Name` checks for:

* 1-character names
* any name ending with a number
* camelCaseVariableNames

## Configuration

Reek's Uncommunicative Method Name detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

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
