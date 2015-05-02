# Duplicate Method Call

## Introduction

Duplication occurs when two fragments of code look nearly identical, or when two fragments of code have nearly identical effects at some conceptual level.
`reek` implements a check for _Duplicate Method Call_.

## Example

Here's a very much simplified and contrived example. The following method will report a warning:

```Ruby
def double_thing()
  @other.thing + @other.thing
end
```

One quick approach to silence Reek would be to refactor the code thus:

```Ruby
def double_thing()
  thing = @other.thing
  thing + thing
end
```

A slightly different approach would be to replace all calls of `double_thing` by calls to `@other.double_thing`:

```Ruby
class Other
  def double_thing()
    thing + thing
  end
end
```

The approach you take will depend on balancing other factors in your code.

## Current support in reek

`reek`'s Duplicate Method Call detector checks for repeated identical method calls within any one method definition. This is intended to complement the checks performed by tools such as [Flay](http://ruby.sadi.st/Flay.html) and [Simian](http://www.redhillconsulting.com.au/products/simian/).

## Configuration

Reek's Duplication detector currently offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

Option | Value | Effect
-------|-------|-------
`max_calls` |  integer | The maximum number of duplicate calls allowed within a method. Defaults to 1.