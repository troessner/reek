# Using `reek` inside your Ruby application

`reek` can be used inside another Ruby project.

```bash
gem install reek
```

## Using a reporter

You can use reek inside your Ruby file `check_dirty.rb`

```ruby
require 'reek'

source = <<-END
  class Dirty
    # This method smells of :reek:NestedIterators but ignores them
    def awful(x, y, offset = 0, log = false)
      puts @screen.title
      @screen = widgets.map { |w| w.each { |key| key += 3 * x } }
      puts @screen.contents
      fail
    end
  end
END

reporter = Reek::CLI::Report::TextReport.new
examiner = Reek::Examiner.new(source)
reporter.add_examiner examiner
reporter.show
```

This will show the list of errors in variable `source`.

`Reek::Examiner.new` can take `source` as `String`, `File` or `IO`.

```
# Examine a file object
reporter.add_examiner Reek::Examiner.new(File.new('dirty.rb'))
```

Also, besides normal text output, `reek` can generate output in YAML,
JSON, HTML and XML by using the following Report types:

```
TextReport
YAMLReport
JSONReport
HTMLReport
XMLReport
```

## Accessing the smell warnings directly

You can also access the smells detected by an examiner directly:

```ruby
require 'reek'

source = <<-END
  class Dirty
    # This method smells of :reek:NestedIterators but ignores them
    def awful(x, y, offset = 0, log = false)
      puts @screen.title
      @screen = widgets.map { |w| w.each { |key| key += 3 * x } }
      puts @screen.contents
      fail
    end
  end
END

examiner = Reek::Examiner.new(source)
examiner.smells.each do |smell|
  puts smell.message
end
```

`Examiner#smells` returns a list of `SmellWarning` objects.
