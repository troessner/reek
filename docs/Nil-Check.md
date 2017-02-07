# Nil Check

## Introduction

A _Nil Check_ is a type check. Failures of _Nil Check_ violate the
["tell, don't ask"](http://robots.thoughtbot.com/tell-dont-ask) principle.
Additionally to that, type checks often mask bigger problems in your source
code like not using OOP and / or polymorphism when you should.

The _Nil Check_ code smell is a case of [Simulated Polymorphism](Simulated-Polymorphism.md).

## Example

Given

```Ruby
class Klass
  def nil_checker(argument)
    if argument.nil?
      puts "argument is nil!"
    end
  end
end
```

Reek would emit the following warning:

```
test.rb -- 1 warning:
  [3]:Klass#nil_checker performs a nil-check. (NilCheck)
```

##  Current Support in Reek

_Nil Check_ reports use of 

* <code>.nil?</code> method
* <code>==</code> and <code>===</code> operators when checking vs. <code>nil</code>
* case statements that use syntax like <code>when nil</code>
* use of the safe navigation operator like `foo&.bar`

## Configuration

_Nil Check_ offers the [Basic Smell Options](Basic-Smell-Options.md).
