# Subclassed From Core Class

## Introduction

Candidate classes for the _Subclassed From Core Class_ smell are classes which inherit from Core Classes like Hash, String and Array.

Inheriting from Core Classes means that you are going to have a bad time debugging (the explanation below is taken from [here](http://words.steveklabnik.com/beware-subclassing-ruby-core-classes)):

> What do you think this code should do?

```Ruby
List = Class.new(Array)

l = List.new
l << 1
l << 2
puts l.reverse.class # => Array
```

> If you said “it prints Array” you’d be right.
> Let’s talk about a more pernicious issue: Strings.

```Ruby
class MyString < String
  def to_s
    "lol"
  end
end

s = MyString.new
s.concat "Hey"

puts s      # => Hey
puts s.to_s # => lol
puts "#{s}" # => Hey
```

> That’s right! With Strings, Ruby doesn’t call #to_s: it puts the value in directly.
> Generally speaking, subclassing isn’t the right idea here.

## Example

Given

```Ruby
class Ary < Array
end

class Str < String
end
```

Reek would report the _Subclassed From Core Class_ smell for both classes. Instead of subclassing them you want a data structure that uses one of these core classes internally, but isn’t exactly like one. For instance:

```Ruby
require 'forwardable'

class List
  extend Forwardable
  def_delegators :@list, :<<, :length # and anything else

  def initialize(list = [])
    @list = list
  end

  def reverse
    List.new(@list.reverse)
  end
end

l = List.new 
l << 1
l << 2
puts l.reverse.class  # => List
```

## Configuration

_Subclassed From Core Class_ offers the [Basic Smell Options](Basic-Smell-Options.md).
