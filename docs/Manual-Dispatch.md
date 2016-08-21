## Introduction

Reek reports a _Manual Dispatch_ smell if it finds source code that manually checks whether an object responds to a method before that method is called. Manual dispatch is a type of [Simulated Polymorphism](Simulated-Polymorphism.md) which leads to code that is harder to reason about, debug, and refactor.

## Example

```Ruby
class MyManualDispatcher
  attr_reader :foo

  def initialize(foo)
    @foo = foo
  end

  def call
    foo.bar if foo.respond_to?(:bar)
  end
end
```

Reek would emit the following warning:

```
test.rb -- 1 warning:
  [9]: MyManualDispatcher manually dispatches method call (ManualDispatch)
```

## Configuration

_Manual Dispatch_ offers the [Basic Smell Options](Basic-Smell-Options.md).
