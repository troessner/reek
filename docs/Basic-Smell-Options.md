# Basic Smell Options

## Introduction

Every smell detector in Reek offers at least the following configuration options:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `enabled` |  Boolean | Determines whether the smell detector is active. Defaults to `true` |
| `exclude` | an array of strings or regular expressions | Ignores any context whose full description (see <strong>%c</strong> in [Command-Line Options](Command-Line-Options.md)) matches any element of this array. |

The file `config/defaults.reek` (shipped with the Reek gem) lists any default exclusions for each smell.

## Examples

<u>An easy one:</u>

To stop Reek reporting smells in any method called `write` you might create a configuration file containing this:

```yaml
ControlCouple: 
  exclude:
  - write
```

Or a little more sophisticated using a ruby regex like this:

```yaml
ControlCouple: 
  exclude:
  - !ruby/regexp /write/
```

<u>A more sophisticated one:</u>

```yaml
FeatureEnvy:
  exclude:
    - "MyModel#do_things"
    - "MyHelper"
    - "ApplicationController#respond"
```

This would not report FeatureEnvy for the instance method `MyModel#do_things`, the whole module `MyHelper` and the `respond` instance method of `ApplicationController`