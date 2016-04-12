# Uncommunicative Variable Name

## Introduction

An _Uncommunicative Variable Name_ is a variable name that doesn't communicate
its intent well enough. This code smell is a case of
[Uncommunicative Name](Uncommunicative-Name.md).

## Current Support in Reek

_Uncommunicative Variable Name_ checks for:

* single-character names
* any name ending with a number
* camelCaseVariableNames

## Configuration

Reek's _Uncommunicative Variable Name_ detector supports the
[Basic Smell Options](Basic-Smell-Options.md), plus:

| Option         | Value       | Effect  |
| ---------------|-------------|---------|
| `reject` | array of regular expressions | The set of regular expressions that Reek uses to check for bad names. Defaults to `[/^.$/, /[0-9]$/, /[A-Z]/]`. |
| `accept` | array of strings or regular expressions | Name that will be accepted (not reported) even if they match one of the `reject` expressions. Defaults to `['_']`.|
