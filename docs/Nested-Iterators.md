# Nested Iterators

## Introduction

A _Nested Iterator_ occurs when a block contains another block.

## Example

Given

```Ruby
class Duck
  class << self
    def duck_names
      %i!tick trick track!.each do |surname|
        %i!duck!.each do |last_name|
          puts "full name is #{surname} #{last_name}"
        end
      end
    end
  end
end
```

Reek would report the following warning:

```
test.rb -- 1 warning:
  [5]:Duck#duck_names contains iterators nested 2 deep (NestedIterators)
```

## Current Support in Reek

_Nested Iterators_ reports failing methods only once.
`Object#tap` is ignored by default and thus does not count as iterator.
Furthermore iterators without block arguments are not counted, e.g.:


```Ruby
def foo
  before do
    item.each do |part|
      puts part
    end
  end
end
```

would not smell of NestedIterators (given a maximum allowed nesting of 1) since the
`before` would not be counted (because it doesn't pass any arguments to the block).

## Configuration

_Nested Iterators_ offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option                | Value   | Effect  |
| ----------------------|---------|---------|
| `max_allowed_nesting` | integer | The maximum depth of nested iterators. Defaults to 1 |
| `ignore_iterators`    | Array   | List of iterators to be excluded from the smell check. Includes only `tap` at the moment|
