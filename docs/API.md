# API

## Using `reek` inside your Ruby application

`reek` can be used inside another Ruby project.

```bash
gem install reek
```

You can use reek inside your Ruby file `check_dirty.rb`

```ruby
require 'reek'
require 'reek/source/source_code'
require 'reek/cli/report/report'
require 'reek/core/examiner'

source =<<END
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

source_code = Reek::Source::SourceCode.from(source)
reporter = Reek::CLI::Report::TextReport.new
reporter.add_examiner Reek::Core::Examiner.new(source_code)
puts reporter.show
```

This will show the list of errors in variable `source`.

`reek` can take `source` as `String`, `File` or `IO`.

Also, besides normal text output, `reek` can also generate output in YAML,
JSON, HTML and XML by using the following Report types:

```
TextReport
YAMLReport
JSONReport
HTMLReport
XMLReport
```
