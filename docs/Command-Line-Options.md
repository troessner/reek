# Command Line Options

## Introduction

reek follows standard Unix convention for passing arguments.

Check out

```Bash
reek -h
```

for details.

## Telling Reek Which Code to Check

Probably the most standard use case would be to check all ruby files in the lib directory:

```Bash
reek lib/*.rb
```

In general, if any command-line argument is a directory, Reek searches that directory and all sub-directories for Ruby source files. Thus

```Bash
reek lib
```

would be equivalent to 

```Bash
reek lib/**/*.rb
```

Occasionally you may want to quickly check a code snippet without going to the trouble of creating a file to hold it. You can pass the snippet directly to Reek's standard input:

```Bash
echo "def x() true end" | reek
```

## Output options

### Output smell's line number

By passing in a "-n" flag to the _reek_ command, the output will suppress the line numbers:

```Bash
$ reek -n mess.rb
```

```
mess.rb -- 2 warnings:
  x doesn't depend on instance state (UtilityFunction)
  x has the name 'x' (UncommunicativeMethodName)
```

Otherwise line numbers will be shown as default at the beginning of each warning in square brackets:

```Bash
$ reek mess.rb
```

```
mess.rb -- 2 warnings:
  [2]:x doesn't depend on instance state (UtilityFunction)
  [2]:x has the name 'x' (UncommunicativeMethodName)
```

### Enable the ultra-verbose mode

_reek_ has a ultra-verbose mode which you might find helpful as a beginner. "ultra-verbose" just means that behind each warning a helpful link will be displayed which leads directly to the corresponding _reek_ wiki page.
This mode can be enabled via the "-U" or "--ultra-verbose" flag.

So for instance, if your test file would smell of _ClassVariable_, this is what the _reek_ output would look like:

```Bash
reek -U test.rb 
```
```
test.rb -- 1 warning:
  [2]:Dummy declares the class variable @@class_variable (ClassVariable) [https://github.com/troessner/reek/wiki/Class-Variable]
```

Note the link at the end.