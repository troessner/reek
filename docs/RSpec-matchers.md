# RSpec matchers

## Introduction

`reek` offers matchers for RSpec you can easily include into your project.

There are 3 matchers available:

- `reek`
- `reek_of`
- `reek_only_of`

## Quickstart

Let's install the dependencies:

```
gem install reek
gem install rspec
```

And then use it like that in your spec file:

```Ruby
require 'reek'
require 'reek/spec'
require 'rspec'

RSpec.describe 'Reek Integration' do
  it 'works with reek' do
    smelly_class = 'class C; def m; end; end'
    expect(smelly_class).not_to reek
  end
end
```

Running this via

```
rspec reek-integration-spec.rb 
```

would give you:

```
Failures:

  1) Reek Integration works with reek
     Failure/Error: expect(smelly_class).not_to reek
       Expected no smells, but got:
         C has no descriptive comment (IrresponsibleModule)
         C has the name 'C' (UncommunicativeModuleName)
         C#m has the name 'm' (UncommunicativeMethodName)
     # ./reek-integration-spec.rb:8:in `block (2 levels) in <top (required)>'

Finished in 0.00284 seconds (files took 0.28815 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./reek-integration-spec.rb:6 # Reek Integration works with reek
```

## The matchers explained

### `reek`

A very generic matcher that basically just tells you if something reeks, but not after what exactly.
See the "Quickstart" example from above.

### `reek_of`

Checks the target source code for instances of "smell category"
and returns true only if it can find one of them that matches.

Remember that this includes our "smell types" as well. So it could be the
"smell type" UtilityFunction, which is represented as a concrete class
in reek but it could also be "Duplication" which is a "smell categgory".

In theory you could pass many different types of input here:
  - :UtilityFunction
  - "UtilityFunction"
  - UtilityFunction (this works in our specs because we tend to do "include Reek:Smells")
  - Reek::Smells::UtilityFunction (the right way if you really want to pass a class)
  - "Duplication" or :Duplication which is an abstract "smell category"

It is recommended to pass this as a symbol like :UtilityFunction. However we don't
enforce this.

Additionally you can be more specific and pass in "smell_details" you
want to check for as well e.g. "name" or "count" (see the examples below).
The parameters you can check for are depending on the smell you are checking for.
For instance "count" doesn't make sense everywhere whereas "name" does in most cases.
If you pass in a parameter that doesn't exist (e.g. you make a typo like "namme") reek will
raise an ArgumentError to give you a hint that you passed something that doesn't make
much sense.

So in a nutshell `reek_of` takes the following two arguments:

- smell_category - The "smell category" or "smell_type" we check for.
- smells_details - A hash containing "smell warning" parameters

**Examples**

 Without smell_details:

```Ruby
  reek_of(:FeatureEnvy)
  reek_of(Reek::Smells::UtilityFunction)
```

With smell_details:

```Ruby
  reek_of(UncommunicativeParameterName, name: 'x2')
  reek_of(DataClump, count: 3)
```

**Examples from a real spec**

```Ruby
  expect(src).to reek_of(Reek::Smells::DuplicateMethodCall, name: '@other.thing')
```

### reek_only_of

See the documentaton for `reek_of`.

**Notable differences to reek_of:**

1.) `reek_of` doesn't mind if there are other smells of a different category. "reek_only_of" will fail in that case.

2.) `reek_only_of` doesn't support the additional smell_details hash.