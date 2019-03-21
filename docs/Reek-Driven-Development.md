# Reek-Driven Development

One way to drive quality into your code from the very beginning of a project is to run Reek as a part of your testing process.

## Rake: `Reek::Rake::Task`

You can add a [Rake Task] to your Rakefile, which will run Reek on all your source files.

```Ruby
require 'reek/rake/task'

Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.verbose = false
  t.source_files = 'lib/**/*.rb'
end
```

Now, `rake reek` will run Reek on your source code. And, in this case, it fails if it finds any smells.

For more detailed information about Reek's integration with Rake, see [Rake Task].

[Rake Task]: Rake-Task.md

## RSpec: `reek/spec`

You can add Reek expectations directly into your RSpec specs.

This example is from Reek's own source code:

```Ruby
require 'reek/spec'

it 'contains no code smells' do
  Pathname.glob('lib/**/*.rb').each do |file|
    expect(file).not_to reek
  end
end
```

By requiring [`reek/spec`] you gain access to the `reek` matcher.

The `reek` matcher returns true if and only if Reek finds smells in your code. If the test fails, the matcher produces an error message that includes details of all the smells it found.

[`reek/spec`]: ../lib/reek/spec.rb

