# Boolean Parameter

## Introduction

_Boolean Parameter_ is a case of [Control Couple](Control-Couple.md), where a
method parameter is defaulted to true or false. A _Boolean Parameter_
effectively permits a method's caller to decide which execution path to take.
This is a case of bad cohesion. You're creating a dependency between methods
that is not really necessary, thus increasing coupling.

## Example

Given

```Ruby
class Dummy
  def hit_the_switch(switch = true)
    if switch
      puts 'Hitting the switch'
      # do other things...
    else
      puts 'Not hitting the switch'
      # do other things...
    end
  end
end
```

Reek would emit the following warning:

```
test.rb -- 3 warnings:
  [1]:Dummy#hit_the_switch has boolean parameter 'switch' (BooleanParameter)
  [2]:Dummy#hit_the_switch is controlled by argument switch (ControlParameter)
```

Note that both smells are reported, _Boolean Parameter_ and _Control Parameter_.

## Getting rid of the smell

This is highly dependant on your exact architecture, but looking at the example above what you could do is:

* Move everything in the `if` branch into a separate method
* Move everything in the `else` branch into a separate method
* Get rid of the `hit_the_switch` method alltogether
* Make the decision what method to call in the initial caller of `hit_the_switch`

## Current support in Reek

Reek can only detect a _Boolean Parameter_ when it has a default initializer like in the example above.

## Configuration

_Boolean Parameter_ supports the [Basic Smell Options](Basic-Smell-Options.md).
