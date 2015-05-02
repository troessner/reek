# Irresponsible Module

## Introduction

Classes and modules are the units of reuse and release. It is therefore considered good practice to annotate every class and module with a brief comment outlining its responsibilities.

## Example

Given

```Ruby
class Dummy
  # Do things...
end
```

`reek` would emit the following warning:

```
test.rb -- 1 warning:
  [1]:Dummy has no descriptive comment (IrresponsibleModule)
```

Fixing this is simple - just an explaining comment:

```Ruby
# The Dummy class is responsible for ...
class Dummy
  # Do things...
end
```

## Current Support in reek

`Irresponsible Module` currently checks classes, but not modules.

## Configuration

`Irresponsible Module` supports only the [Basic Smell Options](Basic-Smell-Options.md).
