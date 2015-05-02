# Control Parameter

## Introduction

`Control Parameter` is a special case of [Control Couple](Control-Couple.md)

## Example

A simple example would be the "quoted" parameter in the following method:

```Ruby
def write(quoted)
  if quoted
    write_quoted @value
  else
    write_unquoted @value
  end
end
```

Fixing those problems is out of the scope of this document but an easy solution could be to remove the "write" method alltogether and to move the calls to "write_quoted" / "write_unquoted" in the initial caller of "write".

## Current Support in reek

`reek` warns about control coupling when a method parameter or block parameter is the tested value in a conditional statement.

## Configuration

Control Couple supports the [Basic Smell Options](Basic-Smell-Options.md).
