# Large Class

## Introduction

A `Large Class` is a class or module that has a large number of instance variables, methods or lines of code in any one piece of its specification. (That is, this smell relates to pieces of the class's specification, not to the size of the corresponding instance of `Class`.)

## Current Support in Reek

`Large Class` reports classes having more than a configurable number of methods or instance variables. The method count includes public, protected and private methods, and excludes methods inherited from superclasses or included modules.

##  Configuration

`reek`'s Large Class detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| max_methods |  integer | The maximum number of methods allowed in a class before a warning is issued. Defaults to 25. |
| max_instance_variables |  integer | The maximum number of instance variables allowed in a class before a warning is issued. Defaults to 9. |

The `Large Class` detector is enabled whenever `reek` is asked to check an instance of `Class` or `Module`.