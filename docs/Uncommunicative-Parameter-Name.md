# Uncommunicative Parameter Name

## Introduction

An `Uncommunicative Parameter Name` is a parameter name that doesn't communicate its intent well enough.

Poor names make it hard for the reader to build a mental picture of what's going on in the code. They can also be mis-interpreted; and they hurt the flow of reading, because the reader must slow down to interpret the names.

## Current Support in reek

`Uncommunicative Parameter Name` checks for:

* 1-character names
* any name ending with a number
* camelCaseVariableNames

## Configuration

`reek`'s Uncommunicative Parameter Name detector supports the [Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `reject` | array of regular expressions | The set of regular expressions that `reek` uses to check for bad names. Defaults to `[/^.$/, /[0-9]$/, /[A-Z]/]@. |
| `accept` | array of strings or regular expressions | Name that will be accepted (not reported) even if they match one of the `reject` expressions. |