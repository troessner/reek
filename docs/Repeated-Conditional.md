# Repeated Conditional

## Introduction

`Repeated Conditional` is a special case of [Simulated Polymorphism](Simulated-Polymorphism.md). Basically it means you are checking the same value throughout a single class and take decisions based on this.

## Example

Given

```Ruby
class RepeatedConditionals
  attr_accessor :switch

  def repeat_1
    puts "Repeat 1!" if switch
  end

  def repeat_2
    puts "Repeat 2!" if switch
  end

  def repeat_3
    puts "Repeat 3!" if switch
  end
end
```

`reek` would emit the following warning:

```
test.rb -- 4 warnings:
  [5, 9, 13]:RepeatedConditionals tests switch at least 3 times (RepeatedConditional)
```

If you get this warning then you are probably not using the right abstraction or even more probable, missing an additional abstraction.

## Configuration

`reek`'s `Repeated Conditional` detector offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `max_ifs` |  integer | The maximum number of identical conditional tests permitted before Reek raises a warning. Defaults to 2. |
