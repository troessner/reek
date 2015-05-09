# Reek Driven Development

## rake

One way to drive quality into your code from the very beginning of a project is to run `reek` as a part of your testing process. For example, you could do that by adding a [Rake Task](Rake-Task.md) to your rakefile, which will make it easy to run `reek` on all your source files whenever you need to.

```Ruby
require 'reek/rake/task'

Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.verbose = false
  t.source_files = 'lib/**/*.rb'
end
```

Now the command `reek` will run `reek` on your source code (and in this case, it fails if it finds any smells). For more detailed information about `reek`'s integration with Rake, see [Rake Task](Rake-Task.md) in this wiki.

## reek/spec

But there's another way; a much more effective "Reek-driven" approach: add `reek` expectations directly into your Rspec specs. Here's an example taken directly from `reek`'s own source code:

```Ruby
it 'contains no code smells' do
  Dir['lib/**/*.rb'].should_not reek
end
```

By requiring "reek/spec":http://reek.rubyforge.org/rdoc/classes/Reek/Spec.html you gain access to the `reek` matcher, which returns true if and only if `reek` finds smells in your code. And if the test fails, the matcher produces an error message that includes details of all the smells it found.

Note: if you're on ruby 1.9  and RSpec2 you should include Reek::Spec in the configuration block like so,

```Ruby
RSpec.configure do |c|
  c.include(Reek::Spec)
end
```

## assert

If you're not yet into BDD with Rspec, you can still gain the benefits of Reek-driven development using assertions:

```Ruby
assert !Dir['lib/**/*.rb'].to_source.smelly?
```
