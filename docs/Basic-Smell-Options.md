# Basic Smell Options

## Introduction

Every smell detector in Reek offers at least the following configuration options:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `enabled` |  Boolean | Determines whether the smell detector is active. Defaults to `true` |
| `exclude` | an array of strings that will be converted into regular expressions | Ignores any context whose full description matches any element of this array. |

The file `docs/defaults.reek.yml` (shipped with the Reek gem) lists any default
exclusions for each smell.

## Examples

**An easy one:**

To stop Reek reporting smells in any method called `write` you might create a configuration file containing this:

```yaml
DuplicateMethodCall:
  exclude:
  - write
```

Internally Reek will convert this to the Regexp /write/.

**A more sophisticated one:**

```yaml
FeatureEnvy:
  exclude:
    - "MyModel#do_things"
    - "MyHelper"
    - "ApplicationController#respond"
```

This would not report FeatureEnvy for the instance method `MyModel#do_things`, the whole module `MyHelper` and the `respond` instance method of `ApplicationController`

## Advanced configuration

Sometimes just strings are not enough for configuration. E.g. consider this code sample:

```Ruby
class Klass
  def foo1; end
  def foo1bar; end
end
```
Both "Klass#foo1" and "Klass#foo1bar" will smell of UncommunicativeMethodName. Now let's assume
you are ok with "Klass#foo1" but not "Klass#foo1bar".
Just having this configuration 

```yaml
UncommunicativeMethodName:
  exclude:
    - "Klass#foo1"
```

wouldn't work because now "Klass#foo1bar" wouldn't smell as well.

For this reason Reek has a special syntax that allows you to use regexes by using a forward slash at the beginning and the end of the string.
Everything within the forward slashes will be loaded as a regex.

A possible configuration that hat excludes "Klass#foo1" from this scan but not "Klass#foo1bar" could look like this:

```yaml
UncommunicativeMethodName:
  exclude:
    - "/Klass#foo1$/"
```

## Reek 4

In Reek 4 you could also pass regexes to `exclude`, meaning this was perfectly valid as well:

```yaml
DuplicateMethodCall:
  exclude:
    - !ruby/regexp /write/
```

Support for this has been scrapped with Reek 5 to make the Reek configuration more yaml standard compliant.
You can still pass in regexes, you just have to wrap them into a string. Please see "Advanced configuration" above.
