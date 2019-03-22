## Reek 4 to Reek 5 migration

### Schema validation

Reek now uses a schema to validate your configuration against on start up and will faily loudly in
case you misspelled an option or used the wrong data type for a value like this:

```
Error: We found some problems with your configuration file: [/detectors/DetectorWithTypo] key 'DetectorWithTypo:' is undefined.
```

Obviously this might affect existing configuration files that until now contained an error nobody noticed.

### Scoping detectors under `detectors`

In Reek 4 you could just configure your detectors on top level like this:

```yaml
UncommunicativeMethodName:
  accept:
    - foobar
UnusedPrivateMethod:
  exclude:
    - app/controllers  
```

In Reek 5 you have to scope your detector configurations under the `detectors` key:

```yaml
detectors:
  UncommunicativeMethodName:
    accept:
      - foobar
  UnusedPrivateMethod:
    exclude:
    - app/controllers  
```

### Move directory directives under a special key

In Reek 4 you could apply directory specific directives like this:

```Yaml
---
"web_app/app/controllers":
  NestedIterators:
    enabled: false
"web_app/app/helpers":
  UtilityFunction:
    enabled: false
```

which was nice and easy but also quite messy. With Reek 5 you'll have to scope this under a `directories`
key like this:

```Yaml
---
directories:
  "web_app/app/controllers":
    NestedIterators:
      enabled: false
  "web_app/app/helpers":
    UtilityFunction:
      enabled: false
```

### No more regular expressions in Reeks configuration

In Reek 4 you could pass regular expressions to the `accept` or `reject` settings of
 
* [Uncommunicative Method Name](Uncommunicative-Method-Name.md)
* [Uncommunicative Module Name](Uncommunicative-Module-Name.md)
* [Uncommunicative Parameter Name](Uncommunicative-Parameter-Name.md)
* [Uncommunicative Variable Name](Uncommunicative-Variable-Name.md)

and to the `exclude` settings which are part of our [Basic Smell Options](docs/Basic-Smell-Options.md).
 
This means that this configuration was perfectly valid:

```yaml
detectors:
  UncommunicativeMethodName:
    accept:
      - !ruby/regexp /foobar/
  UnusedPrivateMethod:
    exclude:
      - !ruby/regexp /i am(.*)unused/  
```

Support for this has been scrapped with Reek 5 to make the Reek configuration more yaml standard compliant.
You can still pass in regexes, you just have to wrap them into a string using a forward slash at the
beginning and at the end of the string like this:

```Yaml
---
UncommunicativeMethodName:
  accept:
    - "/^foobar$/"
UnusedPrivateMethod:
  exclude:
    - "/i am(.*)unused/"  
```

Everything within the forward slashes will be loaded as a regex.

### No more single item shortcuts for list items 

You cant use a configuration option that is supposed to be a list with a single element like this anymore:

```Yaml
---
UncommunicativeMethodName:
  accept: foobar
UnusedPrivateMethod:
  exclude: omg  
```

You'll have to use a proper list here like this:

```Yaml
---
UncommunicativeMethodName:
  accept: 
    - foobar
UnusedPrivateMethod:
  exclude:
    - omg  
```

## Failing on syntax errors in source files

Previously Reek would just continue on syntax errors in source files which might have been convenient but
not necessarily fitting for a tool that's all about code quality. With Reek 5, Reek will fail hard on
invalid source files.

### API changes

This is something that will only affect very advanced users. In case you have no idea what this might be about
you can just skip it or check out our [Developer API](docs/API.md).

#### Allow only detector names in configuration hash

In Reek 4 you could build your configuration like this:

```ruby
config_hash = { Reek::SmellDetectors::IrresponsibleModule => { 'enabled' => false } }
```

or like this:

```ruby
config_hash = { 'IrresponsibleModule' => { 'enabled' => false } }
```

Starting with Reek 5, the first way is not working anymore and the latter one is what you'll have to use.

#### Do not accept a class as parameter for reek_of

In the same vein as the change above you also can't use fully qualified detector names like this:

```Ruby
 reek_of(Reek::SmellDetectors::DuplicateMethodCall)
 ```
 
The only supported way now is either as symbol or string:
 
```Ruby
reek_of(:DuplicateMethodCall)
reek_of('DuplicateMethodCall')
```

## Smaller changes

* `PrimaDonnaMethod` has been given the better name `MissingSafeMethod`
* `wiki-links` flag has been renamed to `documentation` flag
* Reek assumes the default configuration file to be named ".reek.yml" and will ignore all other files. You can
still use any name you want though by passing in a name via the `-c` flag
* We have dropped the legacy code comment separator `:` at the end of a detector name. Before this release,
to configure a smell detector via comment, you had to end with a colon after the detector name.
This syntax is disallowed with Reek 5 - now you have to drop the `:` at the end, like this:

```diff
-# :reek:UnusedPrivateMethod: { exclude: [ bravo ] }
+# :reek:UnusedPrivateMethod { exclude: [ bravo ] }
```

* We have dropped support for Ruby 2.1 and 2.2 since they are officially not supported by the Ruby core team anymore

