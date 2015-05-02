## Introduction

`Too Many Instance Variables` is a special case of `LargeClass`. 

## Example

Given this configuration

```yaml
TooManyInstanceVariables:
  max_instance_variables: 3
```

and this code:

```Ruby
class TooManyInstanceVariables
  def initialize
    @arg_1 = :dummy
    @arg_2 = :dummy
    @arg_3 = :dummy
    @arg_4 = :dummy
  end
end
```

`reek` would emit the following warning:

```
test.rb -- 5 warnings:
  [1]:TooManyInstanceVariables has at least 4 instance variables (TooManyInstanceVariables)
```
## Current Support in `reek`

`reek` only counts the instance variables you use explicitly like in the example above. Class macros like `attr_accessor` are disregarded.

## Configuration

`reek`'s `Too Many Instance Variables` detector offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| max_instance_variables     | integer | The maximum number of instance variables that are permitted. Defaults to 9 |
