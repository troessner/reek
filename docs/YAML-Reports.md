# YAML Reports

## Introduction

`Reek`'s `--yaml` option writes on $stdout a YAML dump of the smells found. Each reported smell has a number of standard fields and a number of fields that are specific to the smell's type. The common fields are as follows:

| Field         | Type       | Value  |
| ---------------|-------------|---------|
| source | string | The name of the source file containing the smell, or `$stdin` |
| lines | array | The source file line number(s) that contribute to this smell |
| context | string | The name of the class, module or method containing the smell |
| class | string | The class to which this smell belongs |
| subclass | string | This smell's subclass within the above class |
| message | string | The message that would have been printed in a standard Reek report |
| is_active | boolean | `false` if the smell is masked by a config file; `true` otherwise |

All of these fields are grouped into hashes `location`, `smell` and `status` (see the examples below).

## Examples

Duplication:

<pre>
- !ruby/object:Reek::SmellWarning 
  location: 
    source: spec/samples/masked/dirty.rb
    lines: 
    - 5
    - 7
    context: Dirty#a
  smell: 
    class: Duplication
    subclass: DuplicateMethodCall
    occurrences: 2
    call: puts(@s.title)
    message: calls puts(@s.title) twice
  status:
    is_active: true
</pre>

[Nested Iterators](Nested-Iterators.md):

<pre>
- !ruby/object:Reek::SmellWarning 
  location: 
    source: spec/samples/masked/dirty.rb
    lines: 
    - 5
    context: Dirty#a
  smell: 
    class: NestedIterators
    subclass: ""
    depth: 2
    message: contains iterators nested 2 deep
  status:
    is_active: true
</pre>

[Uncommunicative Method Name](Uncommunicative-Method-Name.md):

<pre>
- !ruby/object:Reek::SmellWarning 
  location: 
    source: spec/samples/masked/dirty.rb
    lines: 
    - 3
    context: Dirty#a
  smell: 
    class: UncommunicativeName
    subclass: UncommunicativeMethodName
    method_name: a
    message: has the name 'a'
  status:
    is_active: false
</pre>

[Uncommunicative Variable Name](Uncommunicative-Variable-Name.md):

<pre>
- !ruby/object:Reek::SmellWarning 
  location: 
    source: spec/samples/masked/dirty.rb
    lines: 
    - 5
    context: Dirty#a
  smell: 
    class: UncommunicativeName
    subclass: UncommunicativeVariableName
    variable_name: x
    message: has the variable name 'x'
  status:
    is_active: true
</pre>

[Control Couple](Control-Couple.md):

<pre>
- !ruby/object:Reek::SmellWarning 
  location: 
    source: $stdin
    lines: 
    - 2
    context: Turn#fred
  smell: 
    class: ControlCouple
    subclass: BooleanParameter
    parameter: arg
    message: has boolean parameter 'arg'
  status:
    is_active: true
</pre>
