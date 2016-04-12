# Long Parameter List

## Introduction

A _Long Parameter List_ occurs when a method has a lot of parameters.

## Example

Given

```Ruby
class Dummy
  def long_list(foo,bar,baz,fling,flung)
    puts foo,bar,baz,fling,flung
  end
end
```

Reek would report the following warning:

```
test.rb -- 1 warning:
  [2]:Dummy#long_list has 5 parameters (LongParameterList)
```

A common solution to this problem would be the introduction of parameter objects.

## Current Support in Reek

_Long Parameter List_ reports any method or block with more than 3 parameters.

## Configuration

Reek's _Long Parameter List_ detector supports the
[Basic Smell Options](Basic-Smell-Options.md), plus:

| Option       | Value   | Effect  |
| -------------|---------|---------|
| `max_params` | integer | The maximum number of parameters allowed in a method or block before a warning is issued. Defaults to 3. |
