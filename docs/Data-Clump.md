# Data Clump

## Introduction

In general, a `Data Clump` occurs when the same two or three items frequently appear together in classes and parameter lists, or when a group of instance variable names start or end with similar substrings.

The recurrence of the items often means there is duplicate code spread around to handle them. There may be an abstraction missing from the code, making the system harder to understand.

## Example

Given

```Ruby
class Dummy
  def x(y1,y2); end
  def y(y1,y2); end
  def z(y1,y2); end
end
```

`reek` would emit the following warning:

```
test.rb -- 1 warning:
  [2, 3, 4]:Dummy takes parameters [y1, y2] to 3 methods (DataClump)
```

A possible way to fix this problem (quoting from [Martin Fowler](http://martinfowler.com/bliki/DataClump.html)):

>> The first step is to replace data clumps with objects and use the objects whenever you see them. An immediate benefit is that you'll shrink some parameter lists. The interesting stuff happens as you begin to look for behavior to move into the new objects.

## Current Support in Reek

`reek` looks for a group of two or more parameters with the same names that are expected by three or more methods of a class.

## Configuration

Reek's Data Clump detector offers the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| max_copies     | integer | The maximum number of methods that are permitted to take the same group of parameters. Defaults to 2 |
| min_clump_size | integer | The smallest number of parameters that can be reported as a clump. Defaults to 2 |

