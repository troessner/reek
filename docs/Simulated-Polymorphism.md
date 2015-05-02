# Simulated Polymorphism

## Introduction

Simulated Polymorphism occurs when

* code uses a case statement (especially on a type field);
* or code has several if statements in a row (especially if they're comparing against the same value);
* or code uses instance_of?, kind_of?, is_a?, or === to decide what type it's working with;
* or multiple conditionals in different places test the same value.

Conditional code is hard to read and understand, because the reader must hold more state in his head. When the same value is tested in multiple places throughout an application, any change to the set of possible values will require many methods and classes to change. Tests for the type of an object may indicate that the abstraction represented by that type is not completely defined (or understood).

## Current Support in reek

`reek` checks for [Repeated Conditional](Repeated-Conditional.md)  and for [Nil Check](Nil-Check.md).
