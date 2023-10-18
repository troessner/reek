# Duplicate Method Call

## Introduction

Duplication occurs when two fragments of code look nearly identical, or when two fragments of code have nearly identical effects at some conceptual level.

Let's look at an example that is quite common in the Rails world:

```ruby
def not_production?
  Rails.env.development? || Rails.env.test?
end  
```

While this duplicate usage of `Rails.env` might seem innocuous there are 2 problems with it:

1.) Efficiency

```ruby
Rails.env.development? || Rails.env.test?
```

is not as efficient as it could be. If the call to `env` is not memoized your basically paying twice in terms of computation for something that you should only pay once.

Here

```ruby
Rails.env.development? || Rails.env.test?
```

you have 4 method calls while here:

```ruby
env = Rails.env
env.development? || env.test?
```

you have one assignment (which is very cheap in terms of computation) and 3 method calls.
The difference might not be much here but just imagine you're writing a high performance app or you doing some expensive database calls in each method call.

It doesn't really matter though if the efficiency difference is significant. This is a matter of principle - we believe that being efficient is one of the vital traits of good software.

2.) Maintainability

The second point is a bit more subtle. This

```ruby
env = Rails.env
env.development? || env.test?
```

is a lot more intention revealing than 

```ruby
Rails.env.development? || Rails.env.test?
```

Here

```ruby
env = Rails.env
env.development? || env.test?
```

I'm very clear on what I do: I get the environment and then I run some checks on it.

Here

```ruby
Rails.env.development? || Rails.env.test?
```

I'm not very clear on what I do and it requires quite more mental effort: Ok, so I'm talking to Rails, getting the environment and then running a check on it ...or .....oh, I get the same Rails constant again, get the same environment and run another check on it.

## Example

Here's a very much simplified and contrived example. The following method will report a warning:

```ruby
def double_thing
  @other.thing + @other.thing
end
```

One quick approach to silence Reek would be to refactor the code thus:

```ruby
def double_thing
  thing = @other.thing
  thing + thing
end
```

A slightly different approach would be to replace all calls in `double_thing` by calls to `thing`:

```ruby
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

Reek's Duplicate Method Call detector checks for repeated identical method calls within
any one method definition. This is intended to complement the checks performed by tools
such as [Flay](http://ruby.sadi.st/Flay.html) and [Simian](http://www.redhillconsulting.com.au/products/simian/).

## Edge cases

Be aware that there are some edge cases like this code:

```ruby
class Foo
  def bar(switch)
    case switch
    when :a
      ->(arg) { arg.call_me(:maybe); do_something }
    when :b
      ->(arg) { arg.call_me(:maybe); do_something_else }
    when :c
      ->(arg) { arg.call_me(:maybe); do_something_different }
    end
  end
end
```

Reek cannot reliably detect that each call's receiver is a different arg and will report:

```
[5, 7, 9]:DuplicateMethodCall: Foo#bar calls 'arg.call_me(:maybe)' 3 times
```
  
If you're running into this problem you can disable this smell detector for this method either via
configuration:

```yaml
---
DuplicateMethodCall:
  exclude:
    - 'Foo#bar'
```

or via source code comment:

```ruby
class Foo
  # :reek:DuplicateMethodCall
  def bar(switch)
    # ....
  end
end
```

## Configuration

Reek's Duplicate Method Call detector currently offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

Option | Value | Effect
-------|-------|-------
`max_calls` |  integer | The maximum number of duplicate calls allowed within a method. Defaults to 1.
`allow_calls` | an array of strings or regular expressions | Ignores any context who matches it |

## Example configuration

### Adjusting `max_calls`

Imagine code like this:

```ruby
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

```ruby
class Alfa
  # :reek:DuplicateMethodCall { max_calls: 2 }
  def bravo
    charlie.delta
    charlie.delta
  end
end
```

2.) Via configuration file:

```yaml
DuplicateMethodCall:
  max_calls: 2
```

Note though that the latter way will set `max_calls` to 2 for all instances
of the smell detector which might not be what you want - in this case
you'll have to use source code comments.

### Adjusting `allow_calls`

Imagine code like this:

```ruby
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

```ruby
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

```yaml
DuplicateMethodCall:
  allow_calls:
  - 'echo.foxtrot'
```

Note though that the latter way will allow those calls across your source code which might not be what you want.
In this case you'll have to use source code comments.
