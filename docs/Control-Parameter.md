# Control Parameter

## Introduction

_Control Parameter_ is a case of [Control Couple](Control-Couple.md).

## Example

A simple example would be the `quoted` parameter in the following method:

```Ruby
def write(quoted)
  if quoted
    write_quoted @value
  else
    write_unquoted @value
  end
end
```

Fixing those problems is out of the scope of this document but an easy solution
could be to remove the `write` method altogether and to move the calls to
`write_quoted` and `write_unquoted` to the caller of `write`.

## Current Support in Reek

Reek warns about _Control Parameter_ when a method parameter or block parameter is
the tested value in a conditional statement.

## Configuration

_Control Parameter_ supports the [Basic Smell Options](Basic-Smell-Options.md).
