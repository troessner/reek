# Change log

## 4.7.2 (2017-07-24)

* (mvz) Also report unused uncommunicative parameter names
* (mvz) Track visibility correctly when using method definition visibility modifiers
* (mvz) Handle method comments when using method definition visibility modifiers

## 4.7.1 (2017-06-12)

* (mvz) Improve IrresponsibleModule and fix some bugs along

## 4.7.0 (2017-05-31)

* (pocke) Introduce Syntax smell detector

## 4.6.2 (2017-04-27)

* (pocke) Prevent from breaking on a string with escape sequence incompatible with UTF-8
* (pocke) Use Ruby 2.4 parser for parsing code

## 4.6.1 (2017-04-05)

* (IanWhitney) Properly handle absolute paths.

## 4.6.0 (2017-04-04)

* (IanWhitney) Implement `--force-exclusion` flag
* (mvz) Raise Reek-specific error on parse errors

## 4.5.6 (2017-02-17)

* (mvz) Raise on errors inside of Examiner#smells instead of outputting to STDERR
* (mvz) Update parser dependency

## 4.5.5 (2017-02-05)

* (mvz) Load YAML in code comments safely
* (mvz) Combine lines for manual dispatch smells
* (mvz) Respect exclude_paths when passing sources on the command line
* (mvz) Ensure explicit arguments of super() are processed

## 4.5.4 (2017-01-17)

* (troessner) Improve documentation and fix PrimaDonnaMethod detector configuration via comment.

## 4.5.3 (2016-12-05)

* (jhubert) Stop reporting FeatureEnvy with super and arguments.

## 4.5.2 (2016-11-06)

* (troessner) Warn about multiple configuration files.

## 4.5.1 (2016-10-16)

* (troessner) Validate configuration keys in code comments.

## 4.5.0 (2016-10-12)

* (jhubert) Add progress formatters for showing progress on each file
* (mvz) Update progress formatter to match changed file location
* (mvz) Disable progress for piped output
* (maxjacobson) Emit fingerprints in Code Climate reporter

## 4.4.4 (2016-09-29)

* (troessner) Create a fresh todo file on every run
* (troessner) Handle garbage in comment config properly

## 4.4.3 (2016-09-24)

* (troessner) Improve handling of internal errors in detectors and the corresponding error messages

## 4.4.2 (2016-09-21)

* (troessner) Fail properly on bad configuration comments

## 4.4.1 (2016-09-13)

* (troessner) Quote names in smell detector messages
* (troessner) Make our CodeComment regex more lenient
* (troessner) Fix UncommunicativeVariableName does not take regex configuration into account

## 4.4.0 (2016-08-24)

* (waldyr) Add ignored nodes parameter to local_nodes
* (waldyr) Add Instance Variable Assumption smell detector
* (waldyr) Remove memoized instance variables from accounting of TooManyInstanceVariables smell

## 4.3.0 (2016-08-23)

* (backus) Add ManualDispatch smell.

## 4.2.5 (2016-08-23)

* (mvz) Detect safe navigation operator and report on it.

## 4.2.4 (2016-08-15)

* (troessner) Make Reek more resilient on incomprehensible source.
* (troessner) Make our parameter handling consistent in smell detectors.
* (Drenmi) Rename `#inspect` method to `#sniff`

## 4.2.3 (2016-08-05)

* (soutaro) Add SexpExtensions::CSendNode for safe navigation operator

## 4.2.2 (2016-08-02)

* (soutaro) Use bundler to load libs during test

## 4.2.1 (2016-07-20)

* (waldyr) Fix TooManyConstants for outer module when inner module suppress

## 4.2.0 (2016-07-16)

* (waldyr) Add Too Many Constants smell detector

## 4.1.1 (2016-07-05)

* (waldyr) Checking lambda should not raise error

## 4.1.0 (2016-06-23)

* (waldyr) Add SubclassedFromCoreClass detector

## 4.0.5 (2016-06-16)

* (mvz) Handle new lambda syntax in NestedIterators

## 4.0.4 (2016-06-11)

* (troessner) Bump parser

## 4.0.3 (2016-05-23)

* (mvz) Include default exclusions in generated TODO file
* (mvz) Avoid generating duplicate context entries in exclusions

## 4.0.2 (2016-04-23)

* (mvz) Stop UnusedPrivateMethod getting confused by nested classes
* (mvz) Implement and use ShouldReekOf#with_config
* (mvz) Automatically enable smell in reek_of matcher

## 4.0.1 (2016-04-10)

* (thepry) Fix excluded paths for custom config formats.

## 4.0.0 (2016-03-21)

* (troessner) Fix disabling UnusedPrivateMethod via `exclude` in configuration.
* (troessner) Fix `accept` and `reject` configuration handling.
* (troessner) Fix UnusedParameter detector for lvasgn.
* (troessner) Remove deprecated method `from_map` from `AppConfiguration`.
              The successor is `AppConfiguration.from_hash`.

## 4.0.0.pre1 (2016-03-01)

* First pre-release for Reek 4.
* (troessner) Make all optional arguments to Examiner's constructor keyword
  arguments.
* (troessner) Use keyword arguments without defaults as allowed by Ruby 2.1.
* (mvz) Remove smell category concept:
  - The smell category is removed from the YAML and JSON outputs.
  - The smell category can no longer be used to select smells in the reek_of
    matcher.
* (chastell) Make HTML report print to stdout like the other reports
* (troessner) Drop support for CRuby 2.0
* (mvz) Speed up reek_of matcher by only running the given smell

## 3.11 (2016-02-18)

* (troessner) Add a --todo cli flag that will generate a todo list.

## 3.10.2 (2016-02-15)

* (troessner) Bump parser to 2.3.0.6 as minimum to fix problems with invalid syntax.

## 3.10.1 (2016-02-07)

* (mvz) Fix edge case syntax problems
* (troessner) Disable UnusedPrivateMethod detector by default

## 3.10.0 (2016-01-27)

* Add CodeClimate Docker integration. This will allow users to deduct their own docker image
  from the existing one and use it for their own CI set up in whatever ways they see fit.
  Furthermore this will enable users to run `Reek` locally in combination with `codeclimate cli`.

## 3.9.1 (2016-01-24)

* (troessner) Actually use the corresponding parser for Ruby 2.3

## 3.9.0 (2016-01-22)

* (chastell) Bump Parser dependency to support Ruby 2.3
* (mvz) Remove the `unparser` gem as dependency

## 3.8.3 (2016-01-15)

* (avdgaag) Accept FileList as Rake task source file

## 3.8.2 (2016-01-07)

* (pocke) Skip path if path doesn't exist.

## 3.8.1 (2015-12-28)

* (troessner) Don't raise on missing directory for directive.

## 3.8.0 (2015-12-27)

* (troessner) Report unused private instance methods.
* (troessner) Add Rake task for console.

## 3.7.1 (2015-11-29)

* (troessner) Reverse merge default directives into directory directives.

## 3.7.0 (2015-11-17)

* (andyw8) Add Code Climate JSON report format: `--format code_climate`
* (chastell) Simplify `text` report format and enable `--wiki-links` by default

## 3.6.1 (2015-11-13)

* (mvz) Make UtilityFunction not report methods that call `super` with
  arguments.

## 3.6.0 (2015-10-30)

* (mvz) Make Attribute respect suppressing comments
* (chastell) Adjust parser dependency to allow versions 2.2.3+ (and even 2.3+)
* (tansaku + mvz) Allow matches in reek_of for message, lines, context and source.
* (mvz) Deprecate AppConfiguration.from_map in favor of AppConfiguration.from_hash.

## 3.5.0 (2015-09-28)

* (troessner) Ignore iterators without block arguments for NestedIterators

## 3.4.1 (2015-09-24)

* (chastell) Fix parsing `Foo = bar.new(new)`
* (chastell) Sort line numbers in reports of multi-line smells
* (chastell) Fix parsing bare `attr`
* (troessner) Fix `reek_of` not checking `smell_details`
* (chastell) Fix parsing `Foo = new`
* (chastell) Fix parsing `Foo = Class.new do … end.new`

## 3.4.0 (2015-09-16)

* (troessner) Make UtilityFunction configurable for non-public methods
* (troessner) Make FeatureEnvy and UtilityFunction messages more helpful
* (mvz) Mark public API @public

## 3.3.1 (2015-09-03)

* (troessner) Fix file list as argument in rake task
* (troessner) Ignore `Object#tap` for NestedIterators
* (mvz) Ensure all YAML methods are loaded (workaround for #653)

## 3.3.0 (2015-08-23)

* (HParker / Adam Hess) add support for or-assign constants
* (troessner) Update TooManyMethods default value to 15

## 3.2.1 (2015-08-17)

* (troessner) Revert 864f0a9 to hotfix #642

## 3.2.0 (2015-08-17)

* (mvz) Detect attribute writers created with `attr` in Attribute smell
* (beanieboi) Report `attr_writer` and `attr_accessor` in Attribute smell
* (troessner) Update TooManyInstanceVariables default from 9 to 4

## 3.1.0 (2015-07-21)

* (troessner) Make smells configurable on a directory base
* (mvz) Handle modules defined by constant assignment
* (mvz) Handle modifier style use of module_function for UtilityFunction

## 3.0.4 (2015-07-10)

* (troessner) Fix wiki-link cli option.
* (troessner) Recognize singleton methods defined via module function.
* (chastell) Report all envious lines for FeatureEnvy
* (mvz) Report IrresponsibleModule for modules in addition to classes
* (mvz) Do not report IrresponsibleModule for namespace modules

## 3.0.3 (2015-07-04)

* (troessner) Fix finding sources when using just the current directory.

## 3.0.2 (2015-07-03)

* (troessner) Only use Ruby source files.

## 3.0.1 (2015-07-03)

* (troessner) Fix Reek descending into hidden directories

## 3.0.0 (2015-06-30)

* (troessner) Make directories excludable via configuration.
* (mvz) Define and document public API
* (troessner) Recognize methods defined with class << self syntax as singleton methods.
* (troessner)  Use Ruby22 instead of Ruby21 for parsing.
* (nTraum) Drop support for Ruby 1.9

## 2.2.1 (2015-05-11)

* (mvz) Support methods using array decomposition arguments

## 2.2.0 (2015-05-09)

* (sauliusgrigaitis) Add support for XML reports
* (beanieboi) Don’t track private methods in the Attributes smell
* (Sebastian Boehm) Do not enable colorization if stdout is not a TTY

## 2.1.0 (2015-04-17)

* (mvz) Ensure require 'reek' is enough to use Reek's classes
* (mvz) Pick config file that comes first alphabetically
* (mvz) Separate FeatureEnvy and UtilityFunction

## 2.0.4 (2015-04-07)

* (chastell)  Recognise .reek as a valid configuration file

## 2.0.3 (2015-04-06)

* (mvz) Make NestedIterators handle super with arguments
* (mvz) Handle shadow block arguments
* (CoralineAda) Allow all formatters to support -U (wiki links)
* (tuexss) Make defaults transparent in help message

## 2.0.2 (2015-03-15)

* (troessner) Fix version command

## 2.0.1 (2015-03-03)

* (leonelgalan) Add support for json reports
* (chastell) Escape Regexp-like Strings on CodeContext matches (Bug https://github.com/troessner/reek/pull/397)

## 2.0.0 (2015-02-09)

* (troessner) Revise, improve & refactor our Rspec matcher and remove smell_of
* (guilhermesimoes) Fix generating HTML report
* (mvz) Re-organize CLI options
* (maser) Fix file arguments without TTY
* (marcofognog) Make NestedIterator not break if iterator is called on super
* (troessner) Revamp & refactor our rake task

## 1.6.3 (2015-01-15)

* (mvz) Support Ruby 2.2

## 1.6.2 (2015-01-13)

* (mvz) Fix rake task bug when no config file was given explicitly.
* (troessner) Run on working directory when no source is given.

## 1.6.1 (2014-12-20)

* (mvz) Fix regression in rake task: Provide alias for backward compatibility

## 1.6.0 (2014-12-27)

* (troessner) Revise configuration handling:
  Now there are 3 ways of passing Reek a configuration file:
  - Using the cli "-c" switch
  - Having a file ending with .reek either in your current working directory or in a parent directory (more on that later)
  - Having a file ending with .reek in your HOME directory

  The order in which Reek tries to find such a configuration file is exactly
  like above: First Reek checks if we have given it a configuration file
  explicitly via CLI. Then it checks the current working directory for a file and
  if it can't find one, it traverses up the directories until it hits the root
  directory. And lastly, it checks your HOME directory. As soon as Reek detects a
  configuration file it stops searching immediately, meaning that from Reek's
  point of view there exists one configuration file and one configuration only
  regardless of how many ".reek" files you might have on your filesystem.
* (chastell) Add keyword arguments support after switching to 'parser'
* (mvz) Handle nil-block in iterators

## 1.5.1 (2014-12-05)

* (mvz) Fix support for empty block in NestedIterators
* (mvz) Update minimum required Ruby version to 1.9.3
* (chastell) Fix support for required keyword arguments

## 1.5.0 (2014-12-01)

* (mvz) Parse with the parser gem
* (mvz) Add ModuleInitialize smell

## 1.4.0 (2014-11-09)

* (Gilles Leblanc) Corrects UnusedParameter with keyword arguments with splat
* (mvz) Consider block parameter for DuplicateMethodCall
* (mvz) Add support for detecting specific smells
* (troessner) Add ultra verbose warning formatter.

## 1.3.8 (2014-07-07)

* Internal improvements

## 1.3.7 (2014-03-25)

* (gilles-leblanc) Add color to Reek's output
* (mvz) Ignore unused parameters if method calls super in nested context
* (mvz) Only mark parameters uncommunicative if used

## 1.3.6 (2013-12-29)

* (troessner) Add `Prima Donna Method` smell

## 1.3.5 (2013-12-23)

* (troessner) Allow sorting by issue count
* (mvz) Improve cli options

## 1.3.4 (2013-10-14)

* (apiology) Add --single-line option for reporting
* (gilles-leblanc) Allow config files to override default config values
* (gilles-leblanc) Added line numbers by default when you run the reek command
* (mvz) Support Ruby 2.0 syntax

## 1.3.3 (2013-08-27)

* (bf4) Loosen ruby_parser version dependency
* (gilles-leblanc) Added total warning count

## 1.3.2 (2013-08-09)

* (mvz) Allow duplicate calls to variable-like methods
* (mvz) Improve NestedIterators smell detector
* (mvz) Make combination of -n and -q options work

## 1.3.1 (2013-02-02)

* (EmilRehnberg) Added smell for nil checks
* (geoffharcourt) Updated dependencies to use ruby2ruby 2.0.2 and ruby_parser 3.1.1
* (EmilRehnberg) Added command-line option for printing line numbers with the smell lines

## 1.3 (2013-01-19)

* (mvz) Use new ruby_parser 3 and friends
* (EmilRehnberg) Unused parameter smell added
* (dkubb) Fix problem with IrresponsibleModule flagging the same module twice

## 1.2.13 (2012-12-07)

* (mvz) Update to rspec2.
* (petrjanda) Fix undefined method `chr` on an instance of String on Rubinius

## 1.2.12 (2012-06-09)

* (mvz) Use ripper_ruby_parser on Ruby 1.9.3 and up (thus making Reek able
        to parse the new 1.9 hash syntax).

## 1.2.11 (2012-06-08)

* (mvz) Make Bundler a development dependency.

## 1.2.10 (2012-06-05)

* (troessner) Use bundler rake tasks.

## 1.2.9 (2012-06-05)

* (marktabler) Allow single underscore as a variable assignment without triggering UncommunicativeVariableName.

## 1.2.8 (2010-04-26)

### Major Changes
* Smell detectors can be configured or disabled in code comments
  * Comment with `:reek:smell_name` disables the named smell for a class, module or method
  * Comment with `:reek:smell_name:{...}` for more detailed configuration
* Additional config file(s) can be specified:
  * on the command-line using -c
  * via Reek::Rake::Task in the rakefile

### Minor Changes
* Duplication can be configured to ignore specific calls
* IrresponsibleModule now reports scoped module names correctly (#66)
* NestedIterators is now more configurable:
  * Option to specify permitted nesting depth (#14)
  * Option to ignore certain iterator methods

## 1.2.7.3 (2010-03-29)

### Minor Changes
* UtilityFunction no longer reported when local method called in param initializer (#60)
* Spaces removed from smell class names in report output
* Masked smells are no longer reported
  * the -a command-line option has been removed
  * some methods on Examiner are now deprecated
* DataClump no longer needs infinite memory for large classes (#57 again)

## 1.2.7.2 (2010-03-05)

### Minor Changes
* Number of masked smells is no longer shown in report headers
* Masked smells are no longer listed in --yaml reports
* DataClump no longer needs infinite memory for large classes (#57)
* DataClump reports the names of the offending methods in the YAML report
* UncommunicativeMethodName now accepts operator names (+, -, ...)
* Uncommunicative Name now warns about uppercase letters in method & var names

## 1.2.7.1 (2010-02-03)

### Minor Changes
* Fixed crash on a case statement with no condition (#58)

## 1.2.7 (2010-02-01)

### Major Changes
* New option --yaml reports smells in YAML format
* Now require 'reek/rake/task' to use the rake task
* Now require 'reek/spec' to use the Rspec matchers
* Developer API completely revised and documented

### Minor Changes
* New smell: Irresponsible Module (has no meaningful comment)
* ControlCouple no longer checks arguments yielded to blocks
* FeatureEnvy and UtilityFunction are now subclasses of a new smell: LowCohesion
* NestedIterators now reports the nesting depth
* Fixed problem checking for UtilityFunctions in Object
* Improved detection of invalid config files
* Invalid config files are now ignored
* Non-existent files are now ignored

See http://wiki.github.com/kevinrutherford/reek for further details.

## 1.2.6 (2009-11-28)

### Minor Changes
* Corrected display of module methods to use # (#56)

## 1.2.5 (2009-11-19)

### Minor Changes
* Ignores ruby_parser errors and pretends the offending file was empty

## 1.2.4 (2009-11-17)

### Major Changes
* The -f, -c and -s options for formatting smell warnings have been removed

### Minor Changes
* ControlCouple now warns about parameters defaulted to true/false

## 1.2.3 (2009-11-2)

### Minor Changes
* New smell: Attribute (disabled by default)
* Expanded DataClump to check modules (#9)
* Fixed LargeClass to ignore inner classes and modules
* Fixed LargeClass to ignore singleton methods
* Removed support for MyClass.should_not reek due to ParseTree EOL
* Removed internal requiring of 'rubygems'

## 1.2.1 (2009-10-02)

### Minor Changes
* New smell: Class Variable

See http://wiki.github.com/kevinrutherford/reek for details

## 1.2 2009-09-20

### Major Changes
* Reek passes all its tests under Ruby 1.8.6, 1.8.7 and 1.9.1 (fixed #16)
* New smell -- Data Clump:
  * Looks within a class for 3 or more methods taking the same 2 or more parameters
* New smell -- Simulated Polymorphism:
  * Currently only performs basic check for multiple tests of same value
* Reek's output reports are now formatted differently:
  * Reek is no longer silent about smell-free source code
  * Output now reports on all files examined, even if they have no smells
  * Smell warnings are indented in the report; file summary headers are not
  * Reports for multiple sources are run together; no more blank lines
  * Reports in spec matcher failures are quiet (fixed #38)
* The smells masked by `*.reek` config files can now be seen:
  * The header for each source file now counts masked smells
  * The --show-all (-a) option shows masked warnings in the report
* The spec matchers are now accessed by requiring 'reek/adapters/spec'

### Minor Changes
* Reek's RDoc is now hosted at http://rdoc.info/projects/kevinrutherford/reek
* If a dir is passed on the command-line all `**/*.rb` files below it are examined (fixed #41)
* Duplication warnings now report the number of identical calls
* FeatureEnvy no longer ignores :self when passed as a method parameter
* LargeClass is disabled when checking in-memory classes (fixed #28)
* LongParameterList accepts upto 5 parameters for #initialize methods
* Several changes to the LongMethod counting algorithm:
  * LongMethod now counts statements deeper into each method (fixed #25)
  * LongMethod no longer counts control structures, only their contained stmts
  * See http://wiki.github.com/kevinrutherford/reek/long-method for details
* UncommunicativeName warns about any name ending in a number (fixed #18)
* UtilityFunction has been relaxed somewhat:
  * no longer reports methods that call 'super' (fixed #39)
  * no longer reports simple helper methods
  * can be configured based on number of calls out
* Now reports an error for corrupt config files
* Empty config files are ignored
* Smells can be configured with scope-specific overrides for any config item


## 1.1.3 2009-05-19

### Minor Changes
* No longer depends directly on the sexp_processor gem

### Fixes
* LargeClass now relies only on the given source code (fixed #26)

## 1.1.2 2009-05-18

### Major Enhancements
* Switched from ParseTree to ruby_parser for source code parsing
* 'MyClass.should_not reek' now only possible if ParseTree gem installed

## 1.1.1 2009-05-08

### Minor enhancements
* LargeClass now also warns about any class with > 9 instance variables (fixed #6)
* Now depends on ruby2ruby, to display code better
* Duplication notices more repeated method calls
* Smells within blocks are now reported better

## 1.1.0 2009-04-10

### Minor enhancements
* Now possible to write 'MyClass.should_not reek' (fixed #33)

### Fixes
* Now counts attr assignments ([]= etc) in feature envy calculations
* Doesn't attempt to find `*.reek` files when reading code from stdin

## 1.0.1 2009-04-06

### Fixes
* Dir[...].to_source now creates a Report that can be browsed (fixed #36)

## 1.0.0 2009-04-05

### Major enhancements
* Use `*.reek` files in source tree to configure Reek's behaviour
* Added -f option to configure report format
* --sort_order replaced by -f, -c and -s
* Matchers provided for rspec; eg. foo.should_not reek

### Minor enhancements
* Smells in singleton methods are now analysed
* Uncommunicative parameter names in blocks now reported
* Modules and blocks now reflected in scope of smell reports

### Fixes
* Corrected false reports of long arg lists to yield
* A method can now be a UtilityFunction only when it includes a call

## 0.3.1 2008-11-17

### Minor enhancements
* Uncommunicative Name now checks instance variables more thoroughly
* Uncommunicative Name now warns about names of the form 'x2'
* Added check for duplicated calls within a method
* Reduced scope of Feature Envy warnings to cover only overuse of lvars
* Added rdoc comments explaining what each smell is about
* Chained iterators are no longer mis-reported as nested

## 0.3.0 2008-11-02

### Minor enhancements
* New smell: first naive checks for Control Couple
* Reek now only checks sources passed on the command line
* Code snippets can be supplied on the commandline
* Added headings and warnings count when smells in multiple files
* Added Reek::RakeTask to run Reek from rakefiles

### Fixes
* Fixed: Returns exit status 2 when smells are reported
* Fixed: no longer claims an empty method is a Utility Function

## 0.2.3 2008-09-22

* Minor enhancements:
  * Only reports Feature Envy when the method isn't a Utility Function
  * General improvements to assessing Feature Envy
* Tweaks:
  * Fixed: coping with parameterless yield call
  * Fixed: copes with :self as an expression
  * Fixed: displaying the receiver of many more kinds of Feature Envy
  * Fixed: Large Class calculation for Object

## 0.2.2 2008-09-15

* Tweaks:
  * Fixed --version!

## 0.2.1 2008-09-14

* Tweaks:
  * Now works from the source code, instead of requiring each named file
  * Added integration tests that run Reek on a couple of gems

## 0.2.0 2008-09-10

* Minor enhancements:
  * Added --help, --version options
  * Added --sort option to sort the report by smell or by code location

## 0.1.1 2008-09-09

* Some tweaks:
  * Fixed report printing for Feature Envy when the receiver is a block
  * Fixed: successive iterators reported as nested
  * Fixed: Long Method now reports the total length of the method
  * Fixed: each smell reported only once

## 0.1.0 2008-09-09

* 1 minor enhancement:
  * Added a check for nested iterators within a method
* Some tweaks:
  * Begun adding some rdoc
  * Split some of the specs into more meaningful chunks
  * Updated the rakefile so that rcov is no longer the default

## 0.0.1 2008-09-08

* 1 major enhancement:
  * Initial release
