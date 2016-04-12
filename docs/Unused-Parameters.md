## Introduction

_Unused Parameter_ refers to methods with parameters that are unused in scope of the method.

Having unused parameters in a method is code smell because leaving dead code in
a method can never improve the method and it makes the code confusing to read.

## Example

Given:

```Ruby
class Klass
  def unused_parameters(x,y,z)
    puts x,y # but not z
  end
end
```

Reek would emit the following warning:

```
[2]:UnusedParameters: Klass#unused_parameters has unused parameter 'z'
```

## Configuration

_Unused Parameter_ offers the [Basic Smell Options](Basic-Smell-Options.md).
