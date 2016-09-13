# Duplicate Method Call

## Introduction

Duplication occurs when two fragments of code look nearly identical, or when two fragments of code have nearly identical effects at some conceptual level.
Reek implements a check for _Duplicate Method Call_.

## Example

Here's a very much simplified and contrived example. The following method will report a warning:

```Ruby
def double_thing
  @other.thing + @other.thing
end
```

One quick approach to silence Reek would be to refactor the code thus:

```Ruby
def double_thing
  thing = @other.thing
  thing + thing
end
```

A slightly different approach would be to replace all calls in `double_thing` by calls to `thing`:

```Ruby
class Other
  def double_thing
    thing + thing
  end

  def thing
    @other.thing
  end
end
```

The approach you take will depend on balancing other factors in your code.

## Current support in Reek

Reek's Duplicate Method Call detector checks for repeated identical method calls within any one method definition. This is intended to complement the checks performed by tools such as [Flay](http://ruby.sadi.st/Flay.html) and [Simian](http://www.redhillconsulting.com.au/products/simian/).

## Configuration

Reek's Duplicate Method Call detector currently offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

Option | Value | Effect
-------|-------|-------
`max_calls` |  integer | The maximum number of duplicate calls allowed within a method. Defaults to 1.
`allow_calls` | an array of strings or regular expressions | Ignores any context who matches it |

## Example configuration

### Adjusting `max_calls`

Imagine code like this:

```Ruby
class Alfa
  def bravo
    charlie.delta
    charlie.delta
  end
end
```

This would report:

>>
src.rb -- 1 warning:
  [4, 5]:DuplicateMethodCall: Alfa#bravo calls 'charlie.delta' 2 times

If you want to allow those double calls here you can disable it in 2 different ways:

1.) Via source code comment:

```Ruby
class Alfa
  # :reek:DuplicateMethodCall { max_calls: 2 }
  def bravo
    charlie.delta
    charlie.delta
  end
end
```

2.) Via configuration file:

```Yaml
DuplicateMethodCall:
  max_calls: 2
```

Note though that the latter way will set `max_calls` to 2 for all instances
of the smell detector which might not be what you want - in this case
you'll have to use source code comments.

### Adjusting `allow_calls`

Imagine code like this:

```Ruby
class Alfa
  def bravo
    charlie.delta
    charlie.delta
    echo.foxtrot
    echo.foxtrot
  end
end
```

This would report:

>>
src.rb -- 2 warnings:
  [4, 5]:DuplicateMethodCall: Alfa#bravo calls charlie.delta 2 times
  [6, 7]:DuplicateMethodCall: Alfa#bravo calls echo.foxtrot 2 times

So let's say you're ok with the `echo.foxtrot` calls you can stop reporting them like this:

1.) Via source code comment:

```Ruby
class Alfa
  # :reek:DuplicateMethodCall { allow_calls: ['echo.foxtrot'] }
  def bravo
    charlie.delta
    charlie.delta
    echo.foxtrot
    echo.foxtrot
  end
end
```

2.) Via configuration file:

```Yaml
DuplicateMethodCall:
  allow_calls:
  - 'echo.foxtrot'
```

Note though that the latter way will allow those calls across your source code which might not be what you want.
In this case you'll have to use source code comments.
