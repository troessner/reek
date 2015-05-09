# Rake Task

## Introduction

`reek`  provides a Rake task that runs `reek` on a set of source files. In its most simple form you just include something like that in your Rakefile:

```Ruby
require 'reek/rake/task'

Reek::Rake::Task.new do |t|
  t.fail_on_error = false
end
```

In its most simple form, that's it.

When you now run:

```Bash
rake -T
```

you should see

```Bash
rake reek  # Check for code smells
```

## Configuration via task

An more sophisticated rake task that would make use of all available configuration options could look like this:

```Ruby
Reek::Rake::Task.new do |t|
  t.name          = 'custom_rake' # Whatever name you want. Defaults to "reek".
  t.config_file   = 'config/config.reek' # Defaults to nothing.
  t.source_files  = 'vendor/**/*.rb' # Glob pattern to match source files. Defaults to lib/**/*.rb
  t.reek_opts     = '-U'  # Defaults to ''. You can pass all the options here in that are shown by "reek -h"
  t.fail_on_error = false # Defaults to true
  t.verbose       = true  # Defaults to false
end
```

## Configuration via environment variables

You can overwrite the following attributes by environment variables:

- "reek_opts" by using REEK_OPTS
- "config_file" by using REEK_CFG
- "source_files" by using REEK_SRC

An example rake call using environment variables could look like this:

```Bash
REEK_CFG="config/custom.reek" REEK_OPTS="-s" rake reek
```

See also: [Reek-Driven-Development](Reek-Driven-Development.md)