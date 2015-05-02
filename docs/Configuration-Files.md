# Configuration Files

## Configuration loading

Configuring `reek` via configuration file is by far the most powerful way.

There are 3 ways of passing `reek` a configuration file:

1. Using the cli "-c" switch (see [Command Line Options](Command-Line-Options.md))
2. Having a file ending with .reek either in your current working directory or in a parent directory (more on that later)
3. Having a file ending with .reek in your HOME directory

The order in which `reek` tries to find such a configuration file is exactly like above: First `reek` checks if we have given it a configuration file explicitly via CLI. Then it checks the current working directory for a file and if it can't find one, it traverses up the directories until it hits the root directory. And lastly, it checks your HOME directory.

As soon as `reek` detects a configuration file it stops searching immediately, meaning that from `reek`'s point of view there exists one configuration file and one configuration only regardless of how many ".reek" files you might have on your filesystem.

## Configuration options

The first thing you probably want to check out are the [Basic Smell Options](Basic-Smell-Options.md) which are supported by every smell type.
Certain smell types offer a configuration that goes beyond that of the basic smell options - for instance [Data Clump](Data-Clump.md).
All options that go beyond the [Basic Smell Options](Basic-Smell-Options.md) should be documented in the corresponding smell type wiki page but if you want to get a quick and full overview over all possible configurations you can always check out [the default.reek file in this repository](https://github.com/troessner/reek/blob/master/config/defaults.reek).

Here's an excerpt of a `reek` configuration file from a commercial project:

```yaml
---
IrresponsibleModule:
  enabled: false
NestedIterators:
  exclude:
    - "ActiveModelErrorAdder#self.run" # should be refactored
    - "BookingRequests::Transfer#remote_validation"
    - "BookingRequestsController#vehicle_options" # respond_to block
    - "Content::Base#self.expose_fields" # unavoidable due to metaprogramming
DataClump:
  max_copies: 3
  min_clump_size: 3
```
