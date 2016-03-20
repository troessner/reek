# Uncommunicative Module Name

## Introduction

An `Uncommunicative Module Name` is a module name that doesn't communicate its intent well enough.

Poor names make it hard for the reader to build a mental picture of what's going on in the code. They can also be mis-interpreted; and they hurt the flow of reading, because the reader must slow down to interpret the names.

## Current Support in Reek

`Uncommunicative Module Name` checks for:

* 1-character names
* any name ending with a number

## Configuration

Reek's `Uncommunicative Module Name` detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `reject` | array of regular expressions or strings | The set of patterns / names that Reek uses to check for bad names. Defaults to `[/^.$/, /[0-9]$/]`. |
| `accept` | array of regular expressions or strings | The set of patterns / names that Reek will accept (and not report) even if they match one of the `reject` expressions. Empty by default.|

An example configuration could look like this:

```Yaml
---
UncommunicativeModuleName:
  accept:
    - !ruby/regexp /lassy/
    - M
  reject:
    - !ruby/regexp /Helper/
```

Applying a configuration to a source file like this:

```Ruby
class Classy1; end # Should not be reported
class M; end # Should not be reported
class BaseHelper; end # Should be reported
```

Reek would report:

```
smelly.rb -- 1 warning:
  [3]:UncommunicativeModuleName: BaseHelper has the name 'BaseHelper' [https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Module-Name.md]
```
