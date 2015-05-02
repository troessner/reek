# Non ASCII source files


`reek` doesn't offer a direct way to specify that your source file is encoded as UTF-8 etc, but there is a workaround if you need it:

`reek` includes the class [Reek::RakeTask](http://reek.rubyforge.org/rdoc/classes/Reek/RakeTask.html), which makes it easy to run `reek` from a rakefile. And this task has an attribute `ruby_opts`, which is an array of strings to be passed as arguments directly to the Ruby interpreter. So you can use `reek` to check for smells in non-ASCII files by adding something like this to your rakefile: 

```Ruby
require 'reek/rake_task'

Reek::RakeTask.new('utf8_file') do |t|
  t.source_files = "my_utf8_file.rb"
  t.ruby_opts = ["-Ku"]
end
```
