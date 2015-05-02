# Module Initialize

## Introduction

A module is usually a mixin, so when an `#initialize` method is present it is
hard to tell initialization order and parameters so having `#initialize`
in a module is usually a bad idea.

## Example

The `Foo` module below contains a method `initialize`. Although class `B` inherits from `A`, the inclusion of `Foo` stops `A#initialize` from being called.

```Ruby
class A
  def initialize(a)
    @a = a
  end
end

module Foo
  def initialize(foo)
    @foo = foo
  end
end

class B < A
  include Foo

  def initialize(b)
    super('bar')
    @b = b
  end
end
```

A simple solution is to rename `Foo#initialize` and call that method by name:

```Ruby
module Foo
  def setup_foo_module(foo)
    @foo = foo
  end
end

class B < A
  include Foo

  def initialize(b)
    super 'bar'
    setup_foo_module('foo')
    @b = b
  end
end
```

## Current Support in reek

`reek` warns about module initialize when an instance method named `initialize` is present in a module.

## Configuration

Module Initialize supports the [Basic Smell Options](Basic-Smell-Options.md).