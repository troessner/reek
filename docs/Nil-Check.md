# Nil Check

## Introduction

A `NilCheck` is a type check. Failures of `NilCheck` violate the ["tell, don't ask"](http://robots.thoughtbot.com/tell-dont-ask) principle.
Additionally to that, type checks often mask bigger problems in your source code like not using OOP and / or polymorphism when you should.

## Example

Given

```Ruby
class Klass
  def nil_checker(argument)
    if argument.nil?
      puts "argument isn't nil!"
    end
  end
end
```

`reek` would emit the following warning:

```
test.rb -- 1 warning:
  [3]:Klass#nil_checker performs a nil-check. (NilCheck)
```

##  Current Support in Reek

`NilCheck` reports use of 

* <code>.nil?</code> method
* <code>==</code> and <code>===</code> operators when checking vs. <code>nil</code>
* case statements that use syntax like <code>when nil</code>

## Configuration

`Nil Check` offers the [Basic Smell Options](Basic-Smell-Options.md).