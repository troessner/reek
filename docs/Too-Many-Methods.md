## Introduction

`Too Many Methods` is a special case of `LargeClass`. 

## Example

Given this configuration

```yaml
TooManyMethods:
  max_methods: 3
```

and this code:

```Ruby
class TooManyMethods
  def one; end
  def two; end
  def three; end
  def four; end
end
```

`reek` would emit the following warning:

```
test.rb -- 1 warning:
  [1]:TooManyMethods has at least 4 methods (TooManyMethods)
```
## Current Support in `reek`

`reek` counts all the methods it can find in a `class` - instance *and* class methods. So given `max_methods` from above is 4, this:

```Ruby
class TooManyMethods
  class << self
    def one; end
    def two; end
  end

  def three; end
  def four; end
end
```

would cause reek to emit the same warning as in the example above.

## Configuration

`reek`'s `Too Many Methods` detector offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| max_methods     | integer | The maximum number of methods that are permitted. Defaults to 25 |
