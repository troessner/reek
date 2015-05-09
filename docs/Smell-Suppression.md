## Introduction

In some cases, it might be necessary to suppress one or more of `reek`'s smell warnings for a particular method or class. 

Possible reasons for this could be:

* The code is outside of your control and you can't fix it
* `reek` is not the police. You might have legit reasons why your source code is good as it is.

## How to disable smell detection

First and foremost, there are the [Basic Smell Options](Basic-Smell-Options.md) you can use.

Besides from that, you can use special comments, like so:

```ruby
# This method smells of :reek:NestedIterators
def smelly_method foo
  foo.each {|bar| bar.each {|baz| baz.qux}}
end
```

The method `smelly_method` will not be reported. The general pattern is to put the string ':reek:', followed by the smell class, in a comment before the method or class.

It is also possible to specify options for a particular smell detector, like so:

```ruby
# :reek:LongParameterList: { max_params: 4 }
def many_parameters_it_has foo, bar, baz, qux
  # ...
end
```
