# Utility Function

## Introduction

A _Utility Function_ is any instance method that has no dependency on the state of the instance.

_Utility Function_ is heavily related to _[Feature Envy](Feature-Envy.md)_, please check out the explanation there why _Utility Function_ is something you should care about.

## Example

Given

```Ruby
class UtilityFunction
  def showcase(argument)
    argument.to_s + argument.to_i
  end
end
```

Reek would report:

```
test.rb -- 2 warnings:
  [2]:UtilityFunction#showcase doesn't depend on instance state (UtilityFunction)
```

## Current Support in Reek

_Utility Function_ will warn about any method that:

* is non-empty
* does not override an inherited method
* calls at least one method on another object
* doesn't use any of self's instance variables
* doesn't use any of self's methods

## Differences to _Feature Envy_

_[Feature Envy](Feature-Envy.md)_ is only triggered if there are some references to self and _Utility Function_ is triggered if there are no references to self.

## Configuration

Reek's _Utility Function_ detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option                | Value       | Effect  |
| ----------------------|-------------|---------|
| `public_methods_only` | Boolean | Disable this smell detector for non-public methods (which means "private" and "protected") |

A sample configuration file would look like this:

```Yaml
---
UtilityFunction:
  public_methods_only: true
```
