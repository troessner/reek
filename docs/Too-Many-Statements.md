# Too Many Statements

## Introduction

A method with `Too Many Statements` is any method that has a large number of lines.

## Current Support in Reek

`Too Many Statements` warns about any method that has more than 5 statements. `reek`'s smell detector for `Too Many Statements` counts +1 for every simple statement in a method and +1 for every statement within a control structure (`if`, `else`, `case`, `when`, `for`, `while`, `until`, `begin`, `rescue`) but it doesn't count the control structure itself.

So the following method would score +6 in Reek's statement-counting algorithm:

```Ruby
def parse(arg, argv, &error)
  if !(val = arg) and (argv.empty? or /\A-/ =~ (val = argv[0]))
    return nil, block, nil                                         # +1
  end
  opt = (val = parse_arg(val, &error))[1]                          # +2
  val = conv_arg(*val)                                             # +3
  if opt and !arg
    argv.shift                                                     # +4
  else
    val[0] = nil                                                   # +5
  end
  val                                                              # +6
end
```

(You might argue that the two assigments within the first @if@ should count as statements, and that perhaps the nested assignment should count as +2.)

## Configuration

`reek`'s `Too Many Statements` detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `max_statements` |  integer | The maximum number of statements allowed in a method before a warning is issued. Defaults to 5. |

`Too Many Statements`'s default configuration is:

```yaml
---
TooManyStatements:
  enabled: true
  exclude:
  - initialize
  max_statements: 5
```

By default, `initialize` is not checked for length; any class's constructor can be as long as necessary.
