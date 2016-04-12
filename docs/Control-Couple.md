# Control Couple

## Introduction

Control coupling occurs when a method or block checks the value of a parameter
in order to decide which execution path to take. The offending parameter is
often called a _Control Couple_.

Control Coupling is a kind of duplication, because the calling method already knows which path should be taken.

Control Coupling reduces the code's flexibility by creating a dependency
between the caller and callee: any change to the possible values of the
controlling parameter must be reflected on both sides of the call. A _Control
Couple_ also reveals a loss of simplicity: the called method probably has more
than one responsibility, because it includes at least two different code paths.

You can find a good write-up regarding this problem [here](http://solnic.eu/2012/04/11/get-rid-of-that-code-smell-control-couple.html).

## Current Support in Reek

Reek performs the following checks that fall in this category:

* [Control-Parameter](Control-Parameter.md) - a method parameter or block
  parameter is the tested value in a conditional statement
* [Boolean-Parameter](Boolean-Parameter.md) - a method parameter is defaulted
  to `true` or `false`.
