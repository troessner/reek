# Utility Function

## Introduction

A Utility Function is any instance method that has no dependency on the state of the instance.

A Utility Function reduces the code’s ability to communicate intent: code that “belongs” on one class but which is located in another can be hard to find, and may upset the “System of Names” in the host class. A Utility Function also affects the design’s flexibility: A code fragment that is in the wrong class creates couplings that may not be natural within the application’s domain, and creates a loss of cohesion in the unwilling host class.

A Utility Function often arises because it must manipulate other objects (usually its arguments) to get them into a useful form, and one force preventing them (the arguments) doing this themselves is that the common knowledge lives outside the arguments, or the arguments are of too basic a type to justify extending that type. Therefore there must be something which 'knows' about the contents or purposes of the arguments.  That thing would have to be more than just a basic type, because the basic types are either containers which don't know about their contents, or they are single objects which can't capture their relationship with their fellows of the same type. So, this thing with the extra knowledge should be reified into a class, and the utility method will most likely belong there.

## Example

Given

```Ruby
class UtilityFunction
  def showcase(argument)
    argument.to_s + argument.to_i
  end
end
```

`reek` would report:

```
test.rb -- 2 warnings:
  [2]:UtilityFunction#showcase doesn't depend on instance state (UtilityFunction)
```

## Current Support in reek

`Utility Function` will warn about any method that:

* is non-empty
* does not override an inherited method
* calls at least one method on another object
* doesn't use any of self's instance variables
* doesn't use any of self's methods

## Configuration

`reek`'s `Utility Function` detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `max_helper_calls` |  integer | The maximum number of method calls to other objects allowed within a method. Defaults to 2. |
