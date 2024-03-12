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

Good as well:

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

## Example

Running Reek on:

```ruby
class Dummy
  def test
    @ivar
  end
end
```

would report:

```bash
  [1]:InstanceVariableAssumption: Dummy assumes too much for instance variable @ivar
```

Note that this example would trigger this smell warning as well:

```ruby
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

```ruby
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

Directly accessing instance variables is considered a smell because it [breaks encapsulation](https://www.designisrefactoring.com/2015/03/30/organizing-data-self-encapsulation/) and makes it harder to reason about code.

If you don't want to expose those methods as public API just make them private like this:

```ruby
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

## Using Instance Variable Assumption in a Rails context

In ActiveRecord it seems common to use callbacks like `after_initialize` to initialize instance variables as
outlined [here](https://stackoverflow.com/questions/41165520/overriding-applicationrecord-initialize-bad-idea)
or [here](http://blog.dalethatcher.com/2008/03/rails-dont-override-initialize-on.html)
instead of overriding the `initialize` method.
If an instance variable is initialized in such a callback Reek will report it correspondingly.

This would smell for instance:

```ruby
class Sample < ApplicationRecord
  after_initialize do
    @my_var = false
  end
end
```

Since Reek cannot reliably detect that is used in a Rails context we recommend to disable this detector
for "app/models" like this:

```yaml
directories:
  # Your other configuration....
  "app/models":
    InstanceVariableAssumption:
      enabled: false
```

## Configuration

_Instance Variable Assumption_ supports the [Basic Smell Options](Basic-Smell-Options.md).
