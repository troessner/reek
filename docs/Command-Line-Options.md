# Command Line Options

## Introduction

Reek follows standard Unix convention for passing arguments.

Check out

```bash
reek -h
```

for details.

## Telling Reek to use a specific configuration file

In case your configuration file is not in the standard location (that would be your project directory or
whatever directory you're running Reek from) you can specify a configuration file with the `-c` option
like this:

```bash
reek -c /somewhere/on/your/filesystem/reek_config.yml lib/
```

## Telling Reek Which Code to Check

Probably the most standard use case would be to check all Ruby files in the lib directory:

```bash
reek lib/*.rb
```

In general, if any command-line argument is a directory, Reek searches that directory and all sub-directories for Ruby source files. Thus

```bash
reek lib
```

would be equivalent to

```bash
reek lib/**/*.rb
```

Occasionally you may want to quickly check a code snippet without going to the trouble of creating a file to hold it. You can pass the snippet directly to Reek's standard input:

```bash
echo "def x() true end" | reek
```

To just check all Ruby files in the current directory, you can simply run it
with no parameters:

```bash
reek
```

## Telling Reek Which Smells to Detect

You can tell Reek to only check particular smells by using the `--smell`
option and passing in the smell name.

For example, to only check for [Utility Function](Utility-Function.md), you
would use:

```bash
reek --smell UtilityFunction
```

You can select several smells by repeating the `--smell` option like so:

```bash
reek --smell UtilityFunction --smell UncommunicativeMethodName
```

## Telling Reek Which Smells to Exclude

You can tell Reek to exclude specific smells by using the `--exclude-smell`
option and passing in the smell name.

For example, to exclude checking for [Utility Function](Utility-Function.md), you would use:

```bash
reek --exclude-smell UtilityFunction
```

You can select several smells to exclude by repeating the `--exclude-smell` option like so:

```bash
reek --exclude-smell UtilityFunction --exclude-smell IrresponsibleModule
```

## Output options

### Output smell's line number

By passing in a "-n" flag to the _reek_ command, the output will suppress the line numbers:

```bash
$ reek -n mess.rb
```

```
mess.rb -- 2 warnings:
  x doesn't depend on instance state (UtilityFunction)
  x has the name 'x' (UncommunicativeMethodName)
```

Otherwise line numbers will be shown as default at the beginning of each warning in square brackets:

```bash
$ reek mess.rb
```

```
mess.rb -- 2 warnings:
  [2]:x doesn't depend on instance state (UtilityFunction)
  [2]:x has the name 'x' (UncommunicativeMethodName)
```

### Enable the verbose mode

_reek_ has a verbose mode which you might find helpful as a beginner. "verbose" just means that behind each warning a helpful link will be displayed which leads directly to the corresponding _reek_ documentation page.
This mode can be enabled via the "-U" or "--documentation" flag.

So for instance, if your test file would smell of _ClassVariable_, this is what the _reek_ output would look like:

```bash
reek -U test.rb
```
```
test.rb -- 1 warning:
  [2]:Dummy declares the class variable @@class_variable (ClassVariable) [https://github.com/troessner/reek/blob/master/docs/Class-Variable.md]
```

Note the link at the end.
