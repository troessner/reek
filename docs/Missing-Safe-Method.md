# Missing Safe Method

## Introduction

Candidate methods for the _Missing Safe Method_ smell are methods whose names
end with an exclamation mark.

An exclamation mark in method names means (the explanation below is taken from
[here](http://dablog.rubypal.com/2007/8/15/bang-methods-or-danger-will-rubyist)):

> The ! in method names that end with ! means, “This method is dangerous”—or,
> more precisely, this method is the “dangerous” version of an otherwise
> equivalent method, with the same name minus the !. “Danger” is relative; the
> ! doesn’t mean anything at all unless the method name it’s in corresponds to
> a similar but bang-less method name.
>
> So, for example, gsub! is the dangerous version of gsub. exit! is the
> dangerous version of exit. flatten! is the dangerous version of flatten. And
> so forth.

Such a method is called _Missing Safe Method_ if and only if the non-bang
version does not exist and this method is reported as a smell.

Missing Safe Method was formerly known as Prima Donna Method. 

## Example

Given

```ruby
class C
  def foo; end
  def foo!; end
  def bar!; end
end
```

Reek would report the _Missing Safe Method_ smell for `bar!`, but not for `foo!`.

Reek reports this smell only in a class context, not in a module context in order to allow perfectly legit code like this:


```ruby
class Parent
  def foo; end
end

module Dangerous
  def foo!; end
end

class Son < Parent
  include Dangerous
end

class Daughter < Parent
end
```

In this example, Reek would not report the _Missing Safe Method_ smell for the
method `foo` of the `Dangerous` module.

## Configuration

_Missing Safe Method_ offers the [Basic Smell Options](Basic-Smell-Options.md).

## Example configuration via source comment

Imagine code like this:

```ruby
class Alfa
  def bravo!
  end
end
```

This would report:

>>
ruby.rb -- 1 warning:
  [1]:MissingSafeMethod: Alfa has missing safe method 'bravo!'

If you want to suppress this warning you can do this via source comment like this:

```ruby
# :reek:MissingSafeMethod { exclude: [ bravo! ] }
class Alfa
  def bravo!
  end
end
```
