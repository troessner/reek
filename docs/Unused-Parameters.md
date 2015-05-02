## Introduction

`Unused Parameter` refers to methods with parameters that are unused in scope of the method.

Having unused parameters in a method is code smell because leaving dead code in a method can never improve the method and it makes the code confusing to read. 

## Example

Given:

```Ruby
class Klass
  def unused_parameters(x,y,z)
    puts x,y # but not z
  end
end
```

`reek` would emit the following warning:

```
[2]:Klass#unused_parameters has unused parameter 'z' (UnusedParameters)
```

## Configuration

`Unused Parameter` offers the [Basic Smell Options](Basic-Smell-Options.md).