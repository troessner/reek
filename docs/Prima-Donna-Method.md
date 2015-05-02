# Prima Donna Method

## Introduction

A candidate method for the `Prima Donna Method` smell are methods whose names end with an exclamation mark.

An exclamation mark in method names means (the explanation below is taken from [here](http://dablog.rubypal.com/2007/8/15/bang-methods-or-danger-will-rubyist) ):

>>
The ! in method names that end with ! means, “This method is dangerous”—or, more precisely, this method is the “dangerous” version of an otherwise equivalent method, with the same name minus the !. “Danger” is relative; the ! doesn’t mean anything at all unless the method name it’s in corresponds to a similar but bang-less method name.
So, for example, gsub! is the dangerous version of gsub. exit! is the dangerous version of exit. flatten! is the dangerous version of flatten. And so forth.

Such a method is called `Prima Donna Method` if and only if her non-bang version does not exist and this method is reported as a smell.

## Example

Given

```Ruby
class C
  def foo; end
  def foo!; end
  def bar!; end
end
```

`reek` would report `bar!` as `prima donna method` smell but not `foo!`.

`reek` reports this smell only in a class context, not in a module context in order to allow perfectly legit code like this:


```Ruby
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

In this example, `reek` would not report the `prima donna method` smell for the method `foo` of the `Dangerous` module.

## Configuration

`Prima Donna Method` offers the [Basic Smell Options](Basic-Smell-Options.md).