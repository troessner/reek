# Instance Variable Assumption

## Introduction

Classes should not assume that instance variables are set or present outside of the current class definition.

Good:

```ruby
class Foo
  def initialize
    @bar = :foo
  end

  def foo?
    @bar == :foo
  end
end
```

Bad:

```ruby
class Foo
  def go_foo!
    @bar = :foo
  end

  def foo?
    @bar == :foo
  end
end
```

Good:

```ruby
class Foo
  def foo?
    bar == :foo
  end

  def bar
    @bar ||= :foo
  end
end
```

## Example

Running Reek on:

```Ruby
class Dummy
  def test
    @ivar
  end
end
```

would report:

```Bash
  [1]:InstanceVariableAssumption: Dummy assumes too much for instance variable @ivar [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
```

## Current Support in Reek

An instance variable must:

* be set in the constructor
* or be accessed through a method with lazy initialization / memoization.

If not, _Instance Variable Assumption_ will be reported.

## Configuration

_Instance Variable Assumption_ supports the [Basic Smell Options](Basic-Smell-Options.md).
