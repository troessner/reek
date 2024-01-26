# Class Variable

## Introduction

Class variables form part of the global runtime state, and as such make it easy for one part of the system to accidentally or inadvertently depend on another part of the system. So the system becomes more prone to problems where changing something over here breaks something over there. In particular, class variables can make it hard to set up tests (because the context of the test includes all global state).

For a detailed explanation, check out [this article](https://web.archive.org/web/20160714084532/http://4thmouse.com:80/index.php/2011/03/20/why-class-variables-in-ruby-are-a-bad-idea). and [Stackoverflow](https://stackoverflow.com/a/10594849/7798638)

## Example

Given

```ruby
class Dummy
  @@class_variable = :whatever
end
```

Reek would emit the following warning:

```
reek test.rb

test.rb -- 1 warning:
  [2]:Dummy declares the class variable @@class_variable (ClassVariable)
```

## Getting rid of the smell

You can use class-instance variable to mitigate the problem (as also suggested in the linked article above):

```ruby
class Dummy
  @class_variable = :whatever
end
```

##  Configuration

_Class Variable_ supports the [Basic Smell Options](Basic-Smell-Options.md).
