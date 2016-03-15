# Uncommunicative Parameter Name

## Introduction

An `Uncommunicative Parameter Name` is a parameter name that doesn't communicate its intent well enough.

Poor names make it hard for the reader to build a mental picture of what's going on in the code. They can also be mis-interpreted; and they hurt the flow of reading, because the reader must slow down to interpret the names.

## Current Support in Reek

`Uncommunicative Parameter Name` checks for:

* 1-character names
* any name ending with a number
* camelCaseVariableNames

## Configuration

Reek's Uncommunicative Parameter Name detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `reject` | array of regular expressions or strings | The set of regular expressions that Reek uses to check for bad names. Defaults to `[/^.$/, /[0-9]$/, /[A-Z]/]@. |
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
