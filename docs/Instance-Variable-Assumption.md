# Instance Variable Assumption

## Introduction

Classes should not assume that instance variables are set or present outside of the current class definition.

Good:

```Ruby
class Foo
  def initialize
    @bar = :foo
  end

  def foo?
    @bar == :foo
  end
end
```

Good as well:

```Ruby
class Foo
  def foo?
    bar == :foo
  end

  def bar
    @bar ||= :foo
  end
end
```

Bad:

```Ruby
class Foo
  def go_foo!
    @bar = :foo
  end

  def foo?
    @bar == :foo
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

Note that this example would trigger this smell warning as well:

```Ruby
class Parent
  def initialize(omg)
    @omg = omg
  end
end

class Child < Parent
  def foo
    @omg
  end
end
```

The way to address the smell warning is that you should create an `attr_reader` to use `@omg` in the subclass and not access `@omg` directly like this:

```Ruby
class Parent
  attr_reader :omg

  def initialize(omg)
    @omg = omg
  end
end

class Child < Parent
  def foo
    omg
  end
end
```

Directly accessing instance variables is considered a smell because it [breaks encapsulation](http://designisrefactoring.com/2015/03/29/organizing-data-self-encapsulation/) and makes it harder to reason about code.

If you don't want to expose those methods as public API just make them private like this:

```Ruby
class Parent
  def initialize(omg)
    @omg = omg
  end

  private
  attr_reader :omg
end

class Child < Parent
  def foo
    omg
  end
end
```


## Current Support in Reek

An instance variable must:

* be set in the constructor
* or be accessed through a method with lazy initialization / memoization.

If not, _Instance Variable Assumption_ will be reported.

## Configuration

_Instance Variable Assumption_ supports the [Basic Smell Options](Basic-Smell-Options.md).
