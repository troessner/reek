## Introduction

In some cases, it might be necessary to suppress one or more of Reek's smell
warnings for a particular method or class.

Possible reasons for this could be:

* The code is outside of your control and you can't fix it
* Reek is not the police. You might have legit reasons why your source code
  is good as it is.

## How to disable smell detection

There are always the [Basic Smell Options](Basic-Smell-Options.md)
you can use in your configuration file.

But in this document we would like to focus on a completely different
way - via special comments.

A simple example:

```ruby
# This method smells of :reek:NestedIterators
def smelly_method foo
  foo.each {|bar| bar.each {|baz| baz.qux}}
end
```

The method `smelly_method` will not be reported. The general pattern is to put
the string ':reek:', followed by the smell class, in a comment before the
method or class.

## Extended examples

Multiple smells may be configured for the same method or class:

```ruby
# :reek:LongParameterList and :reek:NestedIterators
def many_parameters_it_has foo, bar, baz, qux
  foo.each {|bar| bar.each {|baz| baz.qux(qux)}}
end
```

Or across several lines which is arguably more readable:

```ruby
# :reek:LongParameterList
# :reek:NestedIterators
def many_parameters_it_has foo, bar, baz, qux
  foo.each {|bar| bar.each {|baz| baz.qux(qux)}}
end
```

It is also possible to specify options for a particular smell detector in hash-style:

```ruby
# :reek:LongParameterList { max_params: 4 }
def many_parameters_it_has foo, bar, baz, qux
  # ...
end
```

Every configuration setting that you can pass via configuration file you can
also use via comment.

E.g.:

```ruby
# :reek:TooManyStatements { max_statements: 6 }
def too_many
  # ...
end

# :reek:NestedIterators { max_allowed_nesting: 2 }
def quax
  foo.each {|bar| bar.each {|baz| baz.qux(qux)}}
end

# :reek:DuplicateMethodCall { max_calls: 3 }
def quax
  foo.to_i + foo.to_i + foo.to_i
end
```

Keep in mind that there are also smell detectors that operate on a class or
module level, e.g.:

```ruby
# :reek:TooManyInstanceVariables { max_instance_variables: 8 }
class Klass
  # ...
end
```

To see what smell detector takes what special configuration just check out the
dedicated documentation for this smell detector.
