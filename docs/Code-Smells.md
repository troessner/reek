# Code Smells

Smells are indicators of where your code might be hard to read, maintain or evolve, rather than things that are specifically _wrong_. Naturally this means that Reek is looking towards your code's future (and that can make its reports seem somewhat subjective, of course).

Reek currently includes checks for the following smells:

* [Attribute](Attribute.md) (disabled by default)
* [Class Variable](Class-Variable.md)
* [Control Couple](Control-Couple.md), including
  * [Boolean Parameter](Boolean-Parameter.md)
  * [Control Parameter](Control-Parameter.md)
* [Data Clump](Data-Clump.md)
* [Duplicate Method Call](Duplicate-Method-Call.md)
* [Irresponsible Module](Irresponsible-Module.md)
* [Large Class](Large-Class.md), including
  * [Too Many Instance Variables](Too-Many-Instance-Variables.md)
  * [Too Many Methods](Too-Many-Methods.md)
* [Long Parameter List](Long-Parameter-List.md), and its special case [Long Yield List](Long-Yield-List.md)
* Low Cohesion, including
  * [Feature Envy](Feature-Envy.md)
  * [Utility Function](Utility-Function.md)
* [Module Initialize](Module-Initialize.md)
* [Nested Iterators](Nested-Iterators.md)
* [Prima-Donna-Method](Prima-Donna-Method.md)
* [Simulated Polymorphism](Simulated-Polymorphism.md), including
  * [Nil Check](Nil-Check.md)
  * [Repeated Conditional](Repeated-Conditional.md)
* [Too Many Statements](Too-Many-Statements.md)
* [Uncommunicative Name](Uncommunicative-Name.md), including
  * [Uncommunicative Method Name](Uncommunicative-Method-Name.md)
  * [Uncommunicative Module Name](Uncommunicative-Module-Name.md)
  * [Uncommunicative Parameter Name](Uncommunicative-Parameter-Name.md)
  * [Uncommunicative Variable Name](Uncommunicative-Variable-Name.md)
* [Unused Parameters](Unused-Parameters.md)