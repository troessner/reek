# Class Variable

## Introduction

Class variables form part of the global runtime state, and as such make it easy for one part of the system to accidentally or inadvertently depend on another part of the system. So the system becomes more prone to problems where changing something over here breaks something over there. In particular, class variables can make it hard to set up tests (because the context of the test includes all global state).

For a detailed explanation, check out [this article](http://4thmouse.com/index.php/2011/03/20/why-class-variables-in-ruby-are-a-bad-idea/)

## Example

Given

```Ruby
class Dummy
  @@class_variable = :whatever
end
```

`reek` would emit the following warning:

```
reek test.rb 

test.rb -- 1 warning:
  [2]:Dummy declares the class variable @@class_variable (ClassVariable)
```

## Getting rid of the smell

You can use class-instance variable to mitigate the problem (as also suggested in the linked article above):

```Ruby
class Dummy
  @class_variable = :whatever
end
```

##  Configuration

`Class Variable` supports the [Basic Smell Options](Basic-Smell-Options.md).
