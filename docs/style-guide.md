# Style guide

## Instance variables and getters / setters

We use instance vars only:

- in the constructor
- for [memoization](http://gavinmiller.io/2013/basics-of-ruby-memoization/)

For everything else we use proper getters / setters.

If possible those should be private. We use the [private_attr](https://github.com/jswanner/private_attr) for this, e.g.:

```Ruby
private_attr_reader :configuration
private_attr_writer :failure_message
private_attr_accessor :examiner
```