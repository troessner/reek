# Nested Iterators

## Introduction

A `Nested Iterator` occurs when a block contains another block.

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

`reek` would report the following warning:

```
test.rb -- 1 warning:
  [5]:Duck#duck_names contains iterators nested 2 deep (NestedIterators)
```

## Current Support in Reek

Nested Iterators reports failing methods only once.

## Configuration

`Nested Iterators` offers the [Basic Smell Options](Basic-Smell-Options.md).