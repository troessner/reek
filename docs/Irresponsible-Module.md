# Irresponsible Module

## Introduction

Classes and modules are the units of reuse and release. It is therefore
considered good practice to annotate every class and module with a brief
comment outlining its responsibilities.

For further guideline on how to write good documentation in Ruby, see these
links:
- [Rails API documentation guidelines](http://edgeguides.rubyonrails.org/api_documentation_guidelines.html)
- [Comments tell you why](https://blog.codinghorror.com/code-tells-you-how-comments-tell-you-why/)

## Example

Given

```Ruby
class Dummy
  # Do things...
end
```

Reek would emit the following warning:

```
test.rb -- 1 warning:
  [1]:IrresponsibleModule: Dummy has no descriptive comment
```

Fixing this is simple - just an explaining comment:

```Ruby
# The Dummy class is responsible for ...
class Dummy
  # Do things...
end
```

## Current Support in Reek

_Irresponsible Module_ checks classes and modules, including those
created through `Struct.new` and `Class.new` and directly assigned to a constant.

## Configuration

_Irresponsible Module_ supports only the [Basic Smell Options](Basic-Smell-Options.md).
