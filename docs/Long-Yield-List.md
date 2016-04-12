# Long Yield List

## Introduction

A _Long Yield List_ occurs when a method yields a lot of arguments to the block
it gets passed. It is a special case of [Long Parameter List](Long-Parameter-List.md).

## Example

```Ruby
class Dummy
  def yields_a_lot(foo,bar,baz,fling,flung)
    yield foo,bar,baz,fling,flung
  end
end
```

Reek would report the following warning:

```
test.rb -- 1 warning:
  [4]:Dummy#yields_a_lot yields 5 parameters (LongYieldList)
```

A common solution to this problem would be the introduction of parameter objects.

## Current Support in Reek

Currently _Long Yield List_ reports any method or block with more than 3 parameters.

## Configuration

Reek's _Long Yield List_ detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option       | Value   | Effect  |
| -------------|---------|---------|
| `max_params` | integer | The maximum number of parameters allowed in a method or block before a warning is issued. Defaults to 3. |
