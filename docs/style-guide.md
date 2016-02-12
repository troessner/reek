# Style guide

## Instance variables and getters / setters

We use instance vars only:

- in the constructor
- for [memoization](http://gavinmiller.io/2013/basics-of-ruby-memoization/)

For everything else we use proper getters / setters.

If possible those should be private.
