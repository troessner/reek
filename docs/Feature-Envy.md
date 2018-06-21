# Feature Envy

## Introduction

_Feature Envy_ occurs when a code fragment references another object more often than it references itself, or when several clients do the same series of manipulations on a particular type of object.

_Feature Envy_ reduces the code's ability to communicate intent: code that "belongs" on one class but which is located in another can be hard to find, and may upset the "System of Names" in the host class.

_Feature Envy_ also affects the design's flexibility: A code fragment that is in the wrong class creates couplings that may not be natural within the application's domain, and creates a loss of cohesion in the unwilling host class.

_Feature Envy_ often arises because it must manipulate other objects (usually its arguments) to get them into a useful form, and one force preventing them (the arguments) doing this themselves is that the common knowledge lives outside the arguments, or the arguments are of too basic a type to justify extending that type. Therefore there must be something which 'knows' about the contents or purposes of the arguments.  That thing would have to be more than just a basic type, because the basic types are either containers which don't know about their contents, or they are single objects which can't capture their relationship with their fellows of the same type. So, this thing with the extra knowledge should be reified into a class, and the utility method will most likely belong there.

## Example

Running Reek on:

```Ruby
class Warehouse
  def sale_price(item)
    (item.price - item.rebate) * @vat
  end
end
```

would report:

```Bash
Warehouse#sale_price refers to item more than self (FeatureEnvy)
```

since this:

```Ruby
(item.price - item.rebate)
```

belongs to the Item class, not the Warehouse.

## Current Support in Reek

_Feature Envy_ reports any method that refers to self less often than it refers to (ie. send messages to) some other object.

## Edge cases

Be aware that there are some edge cases like this code:

```Ruby
class Foo
  def initialize
    @map = {
      a: ->(arg) { arg.css('table') },
      b: ->(arg) { arg.css('div') },
      c: ->(arg) { arg.css('span') }
    }
  end
end
```

Reek cannot reliably detect that each call's receiver is a different arg and will report:

```
  [4, 5, 6]:FeatureEnvy: Foo#initialize refers to 'arg' more than self (maybe move it to another class?)
```
  
If you're running into this problem you can disable this smell detector for this method either via
configuration:

```Yaml
---
FeatureEnvy:
  exclude:
    - 'Foo#bar'
```

or via source code comment:

```Ruby
class Foo
  # :reek:FeatureEnvy
  def initialize
    @map = {
    # ....
  end
end
```

## Differences to _Utility Function_

_Feature Envy_ is only triggered if there are some references to self and _[Utility Function](Utility-Function.md)_ is triggered if there are no references to self.

## Configuration

_Feature Envy_ supports the [Basic Smell Options](Basic-Smell-Options.md).
