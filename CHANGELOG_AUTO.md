# Change Log

## [Unreleased](https://github.com/troessner/reek/tree/HEAD)

[Full Changelog](https://github.com/troessner/reek/compare/v3.3.0...HEAD)

**Closed issues:**

- Where are our stars? [\#655](https://github.com/troessner/reek/issues/655)

**Merged pull requests:**

- Attribute no longer disabled by default [\#670](https://github.com/troessner/reek/pull/670) ([tansaku](https://github.com/tansaku))
- Update max\_methods default value in the docs [\#669](https://github.com/troessner/reek/pull/669) ([apuratepp](https://github.com/apuratepp))
- Ensure full psych is loaded [\#664](https://github.com/troessner/reek/pull/664) ([mvz](https://github.com/mvz))
- Improve specs and docs for TreeDresser. [\#663](https://github.com/troessner/reek/pull/663) ([troessner](https://github.com/troessner))
- Increase rubocop's line length limit. [\#661](https://github.com/troessner/reek/pull/661) ([troessner](https://github.com/troessner))
- Refactor spec\_helper. [\#660](https://github.com/troessner/reek/pull/660) ([troessner](https://github.com/troessner))
- Update API docs. [\#623](https://github.com/troessner/reek/pull/623) ([troessner](https://github.com/troessner))

## [v3.3.0](https://github.com/troessner/reek/tree/v3.3.0) (2015-08-22)
[Full Changelog](https://github.com/troessner/reek/compare/v3.2.1...v3.3.0)

**Fixed bugs:**

- Rake release doesn't work anymore with latest bundler [\#643](https://github.com/troessner/reek/issues/643)
- Rake task blows up with ‘Error: No such file - lib/\*\*/\*.rb’ [\#642](https://github.com/troessner/reek/issues/642)
- Make AppConfiguration's initializer flexible enough to deal with different inputs [\#608](https://github.com/troessner/reek/issues/608)

**Closed issues:**

- private method `load' called for Psych:Module [\#653](https://github.com/troessner/reek/issues/653)

**Merged pull requests:**

- Remove spec/gem directory. [\#659](https://github.com/troessner/reek/pull/659) ([troessner](https://github.com/troessner))
- Ensure each file can be individually required [\#658](https://github.com/troessner/reek/pull/658) ([mvz](https://github.com/mvz))
- Use of StringIO requires stringio [\#657](https://github.com/troessner/reek/pull/657) ([mvz](https://github.com/mvz))
- specs: turn all ivars into lets [\#656](https://github.com/troessner/reek/pull/656) ([chastell](https://github.com/chastell))
- Ensure full psych is loaded [\#654](https://github.com/troessner/reek/pull/654) ([mvz](https://github.com/mvz))
- Prepare 3.3.0 release. [\#652](https://github.com/troessner/reek/pull/652) ([troessner](https://github.com/troessner))
- Remove obsolete docs/Configuration-Files.md \(because it's now directly in the README\). [\#649](https://github.com/troessner/reek/pull/649) ([troessner](https://github.com/troessner))
- Add Piotr as author. [\#647](https://github.com/troessner/reek/pull/647) ([troessner](https://github.com/troessner))
- Update TooManyMethods default value to 15. [\#646](https://github.com/troessner/reek/pull/646) ([troessner](https://github.com/troessner))
- Reintroduce access ivar only in constructors [\#644](https://github.com/troessner/reek/pull/644) ([troessner](https://github.com/troessner))
- Check casgn value responds to type [\#639](https://github.com/troessner/reek/pull/639) ([HParker](https://github.com/HParker))
- Refactor configuration loading and make AppConfiguration's initializer more flexible. [\#625](https://github.com/troessner/reek/pull/625) ([troessner](https://github.com/troessner))
- Unify visibility detectors [\#614](https://github.com/troessner/reek/pull/614) ([mvz](https://github.com/mvz))

## [v3.2.1](https://github.com/troessner/reek/tree/v3.2.1) (2015-08-17)
[Full Changelog](https://github.com/troessner/reek/compare/v3.2...v3.2.1)

## [v3.2](https://github.com/troessner/reek/tree/v3.2) (2015-08-17)
[Full Changelog](https://github.com/troessner/reek/compare/v3.1...v3.2)

**Implemented enhancements:**

- Write HTMLReport to STDOUT [\#570](https://github.com/troessner/reek/issues/570)
- Make reek more rails-friendly or add a "rails" mode. [\#529](https://github.com/troessner/reek/issues/529)
- Assigning class variables smell [\#483](https://github.com/troessner/reek/issues/483)

**Fixed bugs:**

- Assigning class variables smell [\#483](https://github.com/troessner/reek/issues/483)

**Merged pull requests:**

- Bump and changelog for 3.2. release. [\#640](https://github.com/troessner/reek/pull/640) ([troessner](https://github.com/troessner))
- Instance variable access clean-up [\#638](https://github.com/troessner/reek/pull/638) ([chastell](https://github.com/chastell))
- Temporarily allow jruby failures. [\#637](https://github.com/troessner/reek/pull/637) ([troessner](https://github.com/troessner))
- Bump Aruba [\#636](https://github.com/troessner/reek/pull/636) ([chastell](https://github.com/chastell))
- Improve README: Tools, integrations and authors. [\#635](https://github.com/troessner/reek/pull/635) ([troessner](https://github.com/troessner))
- Update TooManyInstanceVariables default. [\#634](https://github.com/troessner/reek/pull/634) ([troessner](https://github.com/troessner))
- Refactor our samples cucumber feature. [\#631](https://github.com/troessner/reek/pull/631) ([troessner](https://github.com/troessner))
- I accidentally the whole XMLReport [\#619](https://github.com/troessner/reek/pull/619) ([chastell](https://github.com/chastell))
- Add Rails-friendly mode to README. [\#618](https://github.com/troessner/reek/pull/618) ([troessner](https://github.com/troessner))
- Reimplement yardoc spec and fix a warning [\#616](https://github.com/troessner/reek/pull/616) ([chastell](https://github.com/chastell))
- Capitalise ‘Ruby’ properly [\#615](https://github.com/troessner/reek/pull/615) ([chastell](https://github.com/chastell))
- Attributes smell no readers [\#613](https://github.com/troessner/reek/pull/613) ([mvz](https://github.com/mvz))
- HTMLReport\#show: print to stdout like all the other reports [\#611](https://github.com/troessner/reek/pull/611) ([chastell](https://github.com/chastell))
- Use private\_attr to silence ‘private attribute?’ warnings and refactor SmellRepository a bit [\#610](https://github.com/troessner/reek/pull/610) ([chastell](https://github.com/chastell))
- Improve change log [\#607](https://github.com/troessner/reek/pull/607) ([mvz](https://github.com/mvz))

## [v3.1](https://github.com/troessner/reek/tree/v3.1) (2015-07-21)
[Full Changelog](https://github.com/troessner/reek/compare/v3.0.4...v3.1)

**Implemented enhancements:**

- An option to show column number? [\#601](https://github.com/troessner/reek/issues/601)

**Fixed bugs:**

- Don’t use singleton configuration [\#594](https://github.com/troessner/reek/issues/594)
- Recognize singleton methods defined when module\_function is a scoping modifier [\#582](https://github.com/troessner/reek/issues/582)
- Switch to Pathnames where possible [\#555](https://github.com/troessner/reek/issues/555)

**Closed issues:**

- a new plugin for Atom: Linter-Ruby-Reek [\#603](https://github.com/troessner/reek/issues/603)
- Failure on valid syntax: Parser::SyntaxError: unexpected token tCOLON [\#602](https://github.com/troessner/reek/issues/602)

**Merged pull requests:**

- Pathname switch fixes [\#600](https://github.com/troessner/reek/pull/600) ([chastell](https://github.com/chastell))
- SourceLocator: drop Method\#to\_proc’s cleverness [\#598](https://github.com/troessner/reek/pull/598) ([chastell](https://github.com/chastell))
- Use Pathnames where possible [\#596](https://github.com/troessner/reek/pull/596) ([chastell](https://github.com/chastell))
- Handle casgn style class definitions [\#595](https://github.com/troessner/reek/pull/595) ([mvz](https://github.com/mvz))
- Make smells configurable on a directory base. [\#593](https://github.com/troessner/reek/pull/593) ([troessner](https://github.com/troessner))
- Actually reset AppConfiguration [\#591](https://github.com/troessner/reek/pull/591) ([chastell](https://github.com/chastell))
- Handle modifier style use of module\_function for UtilityFunction [\#590](https://github.com/troessner/reek/pull/590) ([mvz](https://github.com/mvz))
- Improve Context classes and TreeWalker [\#585](https://github.com/troessner/reek/pull/585) ([mvz](https://github.com/mvz))

## [v3.0.4](https://github.com/troessner/reek/tree/v3.0.4) (2015-07-10)
[Full Changelog](https://github.com/troessner/reek/compare/v3.0.3...v3.0.4)

**Implemented enhancements:**

- IrresponsibleModule does not work on modules [\#485](https://github.com/troessner/reek/issues/485)

**Fixed bugs:**

- wiki deleted? [\#586](https://github.com/troessner/reek/issues/586)
- IrresponsibleModule does not work on modules [\#485](https://github.com/troessner/reek/issues/485)
- Last pending spec [\#480](https://github.com/troessner/reek/issues/480)
- module\_function does not disable Utility Function [\#27](https://github.com/troessner/reek/issues/27)

**Closed issues:**

- IrresponsibleModule triggers when a class defined in multiple files does not have descriptive comments for all files [\#573](https://github.com/troessner/reek/issues/573)

**Merged pull requests:**

- Fix wiki-link cli option. [\#588](https://github.com/troessner/reek/pull/588) ([troessner](https://github.com/troessner))
- Ensure presence of overrideable method [\#584](https://github.com/troessner/reek/pull/584) ([mvz](https://github.com/mvz))
- Update contributing document: Get rid of gitflow. [\#581](https://github.com/troessner/reek/pull/581) ([troessner](https://github.com/troessner))
- Target JRuby with Ruby 2.0 support [\#579](https://github.com/troessner/reek/pull/579) ([chastell](https://github.com/chastell))
- Move \(and rename\) HTMLReport template closer to HTMLReport [\#577](https://github.com/troessner/reek/pull/577) ([chastell](https://github.com/chastell))
- Improve IrresponsibleModule [\#576](https://github.com/troessner/reek/pull/576) ([mvz](https://github.com/mvz))
- Move report option mapping into Report [\#575](https://github.com/troessner/reek/pull/575) ([mvz](https://github.com/mvz))
- Bump dev dependencies [\#572](https://github.com/troessner/reek/pull/572) ([chastell](https://github.com/chastell))
- ObjectRefs: track lines for FeatureEnvy [\#569](https://github.com/troessner/reek/pull/569) ([chastell](https://github.com/chastell))
- Redo Report::HTMLReport\#show and its spec [\#568](https://github.com/troessner/reek/pull/568) ([chastell](https://github.com/chastell))
- Recognize singleton methods defined via module function. [\#567](https://github.com/troessner/reek/pull/567) ([troessner](https://github.com/troessner))

## [v3.0.3](https://github.com/troessner/reek/tree/v3.0.3) (2015-07-04)
[Full Changelog](https://github.com/troessner/reek/compare/v3.0.2...v3.0.3)

**Fixed bugs:**

- reek . is broken [\#562](https://github.com/troessner/reek/issues/562)
- Reek 3.0 tries to parse everything \(even non ruby files\) [\#557](https://github.com/troessner/reek/issues/557)

**Merged pull requests:**

- Fix finding sources when using just the current directory. [\#564](https://github.com/troessner/reek/pull/564) ([troessner](https://github.com/troessner))
- Configure MultilineOperationIndentation cop [\#563](https://github.com/troessner/reek/pull/563) ([mvz](https://github.com/mvz))

## [v3.0.2](https://github.com/troessner/reek/tree/v3.0.2) (2015-07-03)
[Full Changelog](https://github.com/troessner/reek/compare/v3.0.1...v3.0.2)

**Merged pull requests:**

- Only use ruby source files. [\#560](https://github.com/troessner/reek/pull/560) ([troessner](https://github.com/troessner))

## [v3.0.1](https://github.com/troessner/reek/tree/v3.0.1) (2015-07-03)
[Full Changelog](https://github.com/troessner/reek/compare/v3.0.0...v3.0.1)

**Implemented enhancements:**

- Global Exclusions? [\#349](https://github.com/troessner/reek/issues/349)

**Closed issues:**

- Getting reek 3 out now [\#549](https://github.com/troessner/reek/issues/549)
- Define reeks public API [\#528](https://github.com/troessner/reek/issues/528)

**Merged pull requests:**

- Fix reek descending into hidden directories. [\#559](https://github.com/troessner/reek/pull/559) ([troessner](https://github.com/troessner))

## [v3.0.0](https://github.com/troessner/reek/tree/v3.0.0) (2015-06-30)
[Full Changelog](https://github.com/troessner/reek/compare/v2.2.1...v3.0.0)

**Implemented enhancements:**

- Odd case of FeatureEnvy [\#260](https://github.com/troessner/reek/issues/260)

**Fixed bugs:**

- Kill the core [\#522](https://github.com/troessner/reek/issues/522)
- Refactoring /core part 1 [\#517](https://github.com/troessner/reek/issues/517)
- random test failures for rbx-2 [\#507](https://github.com/troessner/reek/issues/507)
- Reek fails on methods with unpacked parameters – undefined method `optional\_argument?' for \(mlhs \(NoMethodError\) ... [\#502](https://github.com/troessner/reek/issues/502)
- Integrate Ataru to make test codeblocks on documentation files [\#472](https://github.com/troessner/reek/issues/472)
- FeatureEnvy is inconsistent [\#215](https://github.com/troessner/reek/issues/215)
- FeatureEnvy is inconsistent [\#215](https://github.com/troessner/reek/issues/215)
- Class methods defined via the "class \<\< self; end" syntax trigger UtilityFunction [\#112](https://github.com/troessner/reek/issues/112)
- FeatureEnvy can miss envious instance variables [\#31](https://github.com/troessner/reek/issues/31)

**Closed issues:**

- Drop ruby 1.9 support [\#527](https://github.com/troessner/reek/issues/527)
- Git Flow [\#515](https://github.com/troessner/reek/issues/515)

**Merged pull requests:**

- Pull up Report namespace [\#551](https://github.com/troessner/reek/pull/551) ([mvz](https://github.com/mvz))
- Make directories excludable via configuration. [\#550](https://github.com/troessner/reek/pull/550) ([troessner](https://github.com/troessner))
- Fix Travis on JRuby-HEAD using explicit opts [\#547](https://github.com/troessner/reek/pull/547) ([bf4](https://github.com/bf4))
- Feature/refactor ast node and sexp node [\#545](https://github.com/troessner/reek/pull/545) ([troessner](https://github.com/troessner))
- Create and document stable API [\#544](https://github.com/troessner/reek/pull/544) ([mvz](https://github.com/mvz))
- Integrate Ataru. [\#540](https://github.com/troessner/reek/pull/540) ([troessner](https://github.com/troessner))
- Recognize methods defined with class \<\< self syntax as singleton methods. [\#539](https://github.com/troessner/reek/pull/539) ([troessner](https://github.com/troessner))
- Yard doc'ing reek internals and improving documentation. [\#538](https://github.com/troessner/reek/pull/538) ([troessner](https://github.com/troessner))
- Use our own AST node abstraction rather than the parser gem abstracti… [\#537](https://github.com/troessner/reek/pull/537) ([troessner](https://github.com/troessner))
- Drop unnecessary module qualification in 'ast/' namespace. [\#536](https://github.com/troessner/reek/pull/536) ([troessner](https://github.com/troessner))
- Fix annoying warning under ruby22 and refactor spec set up. [\#535](https://github.com/troessner/reek/pull/535) ([troessner](https://github.com/troessner))
- Use ruby22 instead of ruby21 for parsing. [\#534](https://github.com/troessner/reek/pull/534) ([troessner](https://github.com/troessner))
- Kill the core. [\#532](https://github.com/troessner/reek/pull/532) ([troessner](https://github.com/troessner))
- Drop support for Ruby 1.9 [\#531](https://github.com/troessner/reek/pull/531) ([nTraum](https://github.com/nTraum))
- Require smells explicitly and fix some missing require\_relatives [\#525](https://github.com/troessner/reek/pull/525) ([chastell](https://github.com/chastell))
- Improve irresponsible module [\#524](https://github.com/troessner/reek/pull/524) ([mvz](https://github.com/mvz))
- Pin parser to 2.2.2.2 to fix our CI build. [\#523](https://github.com/troessner/reek/pull/523) ([troessner](https://github.com/troessner))
- Improve "How reek works". [\#521](https://github.com/troessner/reek/pull/521) ([troessner](https://github.com/troessner))
- Move WarningCollector to /cli. [\#520](https://github.com/troessner/reek/pull/520) ([troessner](https://github.com/troessner))
- Move smell-related classes out of /core to /smells. [\#519](https://github.com/troessner/reek/pull/519) ([troessner](https://github.com/troessner))
- Feature/refactor core dir [\#518](https://github.com/troessner/reek/pull/518) ([troessner](https://github.com/troessner))
- Improve documentation for FeatureEnvy and UtilityFunction. [\#511](https://github.com/troessner/reek/pull/511) ([troessner](https://github.com/troessner))

## [v2.2.1](https://github.com/troessner/reek/tree/v2.2.1) (2015-05-11)
[Full Changelog](https://github.com/troessner/reek/compare/2.2.0...v2.2.1)

**Fixed bugs:**

- Remove all wiki pages [\#508](https://github.com/troessner/reek/issues/508)
- Fix duplicate method call in SexpFormatter. [\#473](https://github.com/troessner/reek/issues/473)

**Closed issues:**

- New release 2.2! [\#510](https://github.com/troessner/reek/issues/510)

**Merged pull requests:**

- Hotfix: Handle array decomposition [\#514](https://github.com/troessner/reek/pull/514) ([mvz](https://github.com/mvz))

## [2.2.0](https://github.com/troessner/reek/tree/2.2.0) (2015-05-09)
[Full Changelog](https://github.com/troessner/reek/compare/v2.2.0...2.2.0)

## [v2.2.0](https://github.com/troessner/reek/tree/v2.2.0) (2015-05-09)
[Full Changelog](https://github.com/troessner/reek/compare/v2.1.0...v2.2.0)

**Fixed bugs:**

- Link to /docs from all relevant source files [\#499](https://github.com/troessner/reek/issues/499)
- Move all of our wiki pages into the /docs folder and change inbound links [\#482](https://github.com/troessner/reek/issues/482)
- Drop UtilityFunction configuration parameter max\_helper\_calls [\#441](https://github.com/troessner/reek/issues/441)
- Restructure modules [\#438](https://github.com/troessner/reek/issues/438)
- Versioning policy? [\#422](https://github.com/troessner/reek/issues/422)
- Refactor CodeParser and friends [\#395](https://github.com/troessner/reek/issues/395)
- Isolate integration tests [\#361](https://github.com/troessner/reek/issues/361)
- Feature Envy reported even when it is reporting Utility Function [\#53](https://github.com/troessner/reek/issues/53)

**Closed issues:**

- enhance reek\_of matcher to enable smell during testing. [\#505](https://github.com/troessner/reek/issues/505)
- Can't disable ToomanyStatements in .reek file [\#504](https://github.com/troessner/reek/issues/504)
- rspec enhancements [\#497](https://github.com/troessner/reek/issues/497)
- Cleanup Attributes Smell spec [\#495](https://github.com/troessner/reek/issues/495)
- Detect misused caching [\#484](https://github.com/troessner/reek/issues/484)
- `bundle exec rake` noisy, outputs warnings, should this be fixed? [\#470](https://github.com/troessner/reek/issues/470)
- End warnings with a final newline [\#465](https://github.com/troessner/reek/issues/465)
- Crash when scanning view helper from Rails project [\#463](https://github.com/troessner/reek/issues/463)
- release management [\#446](https://github.com/troessner/reek/issues/446)

**Merged pull requests:**

- Revamp our doc structure. [\#509](https://github.com/troessner/reek/pull/509) ([troessner](https://github.com/troessner))
- Cleanup attribute smell spec [\#501](https://github.com/troessner/reek/pull/501) ([beanieboi](https://github.com/beanieboi))
- Refactor ReferenceCollector call counting [\#500](https://github.com/troessner/reek/pull/500) ([chastell](https://github.com/chastell))
- rspec enhancements [\#498](https://github.com/troessner/reek/pull/498) ([beanieboi](https://github.com/beanieboi))
- Document SourceCode\#syntax\_tree [\#496](https://github.com/troessner/reek/pull/496) ([troessner](https://github.com/troessner))
- Move wiki pages to /docs. [\#494](https://github.com/troessner/reek/pull/494) ([troessner](https://github.com/troessner))
- Small DuplicateMethodCall refactoring. [\#493](https://github.com/troessner/reek/pull/493) ([troessner](https://github.com/troessner))
- Update README to link to our API docs. [\#490](https://github.com/troessner/reek/pull/490) ([troessner](https://github.com/troessner))
- Improve YARD output [\#489](https://github.com/troessner/reek/pull/489) ([mvz](https://github.com/mvz))
- Explain load order issue [\#488](https://github.com/troessner/reek/pull/488) ([mvz](https://github.com/mvz))
- Refactor sexp. [\#487](https://github.com/troessner/reek/pull/487) ([troessner](https://github.com/troessner))
- Ensure running bin/reek from checkout works [\#486](https://github.com/troessner/reek/pull/486) ([mvz](https://github.com/mvz))
- don’t track private methods in the Attributes smell [\#481](https://github.com/troessner/reek/pull/481) ([beanieboi](https://github.com/beanieboi))
- Added instruction to use reek in ruby code [\#479](https://github.com/troessner/reek/pull/479) ([bibstha](https://github.com/bibstha))
- Improve sexp formatter output and remove DuplicateMethodCalls. [\#478](https://github.com/troessner/reek/pull/478) ([clemenshelm](https://github.com/clemenshelm))
- Fix "interperter" typo in spec filename [\#477](https://github.com/troessner/reek/pull/477) ([sometimesfood](https://github.com/sometimesfood))
- Travis: notify GitHub all is well before allowed failures finish [\#476](https://github.com/troessner/reek/pull/476) ([chastell](https://github.com/chastell))
- Silence factory\_girl warnings [\#475](https://github.com/troessner/reek/pull/475) ([bruno-](https://github.com/bruno-))
- Update quality spec to new rspec syntax [\#474](https://github.com/troessner/reek/pull/474) ([bruno-](https://github.com/bruno-))
- Do not enable colorization if stdout is not a TTY [\#471](https://github.com/troessner/reek/pull/471) ([sometimesfood](https://github.com/sometimesfood))
- Remove ruby management related files [\#469](https://github.com/troessner/reek/pull/469) ([bruno-](https://github.com/bruno-))
- Extract method to reduce ABC size [\#467](https://github.com/troessner/reek/pull/467) ([andyw8](https://github.com/andyw8))
- Refactor sources [\#466](https://github.com/troessner/reek/pull/466) ([troessner](https://github.com/troessner))
- NilCheck: drop the dot from the message [\#464](https://github.com/troessner/reek/pull/464) ([chastell](https://github.com/chastell))
- Refactor SmellWarning\#yaml\_hash and lower max ABC size by 2 [\#462](https://github.com/troessner/reek/pull/462) ([chastell](https://github.com/chastell))
- ConfigurationFileFinder spec: don’t fail on config in tempdir [\#461](https://github.com/troessner/reek/pull/461) ([chastell](https://github.com/chastell))
- Sort SmellRepository.smell\_types by name [\#460](https://github.com/troessner/reek/pull/460) ([chastell](https://github.com/chastell))
- Clean up RuboCop config [\#459](https://github.com/troessner/reek/pull/459) ([chastell](https://github.com/chastell))
- Better/new {,Singleton}MethodContext\#envious\_receivers tests [\#458](https://github.com/troessner/reek/pull/458) ([chastell](https://github.com/chastell))
- Add link to overcommit under "Tools" [\#457](https://github.com/troessner/reek/pull/457) ([lencioni](https://github.com/lencioni))
- README and CONTRIBUTING clean-up [\#456](https://github.com/troessner/reek/pull/456) ([chastell](https://github.com/chastell))
- ConfigurationFileFinder: test magic paths [\#455](https://github.com/troessner/reek/pull/455) ([chastell](https://github.com/chastell))
- Move spec.rb back to top level. [\#454](https://github.com/troessner/reek/pull/454) ([troessner](https://github.com/troessner))
- Drop require\_all and side-step circular require [\#453](https://github.com/troessner/reek/pull/453) ([chastell](https://github.com/chastell))
- UtilityFunction: drop max\_helper\_calls [\#452](https://github.com/troessner/reek/pull/452) ([chastell](https://github.com/chastell))
- Reorganize "core" and "source" modules. [\#451](https://github.com/troessner/reek/pull/451) ([troessner](https://github.com/troessner))
- Added Checkstyle format XML report support [\#450](https://github.com/troessner/reek/pull/450) ([sauliusgrigaitis](https://github.com/sauliusgrigaitis))
- Update contributing with gitflow. [\#448](https://github.com/troessner/reek/pull/448) ([troessner](https://github.com/troessner))

## [v2.1.0](https://github.com/troessner/reek/tree/v2.1.0) (2015-04-17)
[Full Changelog](https://github.com/troessner/reek/compare/v2.0.4...v2.1.0)

**Fixed bugs:**

- Test classes by full name [\#443](https://github.com/troessner/reek/issues/443)
- Remove core\_extras monkeypatches [\#433](https://github.com/troessner/reek/issues/433)
- Contribution guidelines [\#423](https://github.com/troessner/reek/issues/423)
- Make development calls to reek behave more sane [\#406](https://github.com/troessner/reek/issues/406)
- Refactor our specs [\#330](https://github.com/troessner/reek/issues/330)

**Closed issues:**

- I've made a Reek plugin for Atom [\#431](https://github.com/troessner/reek/issues/431)

**Merged pull requests:**

- Drop self-includes to lessen namespace pollution [\#445](https://github.com/troessner/reek/pull/445) ([chastell](https://github.com/chastell))
- Pick config file that comes first alphabetically [\#442](https://github.com/troessner/reek/pull/442) ([mvz](https://github.com/mvz))
- Properly capitalise acronyms in class names [\#440](https://github.com/troessner/reek/pull/440) ([chastell](https://github.com/chastell))
- Remove the unnecessary "SourceFile" abstraction. [\#439](https://github.com/troessner/reek/pull/439) ([troessner](https://github.com/troessner))
- Add @chastell to Travis notifications [\#437](https://github.com/troessner/reek/pull/437) ([chastell](https://github.com/chastell))
- Remove source rb [\#436](https://github.com/troessner/reek/pull/436) ([troessner](https://github.com/troessner))
- Remove core\_extras. [\#435](https://github.com/troessner/reek/pull/435) ([troessner](https://github.com/troessner))
- First cut of contribution guidelines [\#434](https://github.com/troessner/reek/pull/434) ([chastell](https://github.com/chastell))
- README: reformat Tools and link the Atom plugin [\#432](https://github.com/troessner/reek/pull/432) ([chastell](https://github.com/chastell))
- Clean-up gemspec and bump rubocop and cucumber [\#430](https://github.com/troessner/reek/pull/430) ([chastell](https://github.com/chastell))
- Simplify ConfigurationFileFinder spec a bit [\#429](https://github.com/troessner/reek/pull/429) ([chastell](https://github.com/chastell))
- Refactor ConfigurationFileFinder and its spec [\#428](https://github.com/troessner/reek/pull/428) ([chastell](https://github.com/chastell))
- Switch all local requires to require\_relative [\#427](https://github.com/troessner/reek/pull/427) ([chastell](https://github.com/chastell))
- Separate feature envy from utility function [\#418](https://github.com/troessner/reek/pull/418) ([mvz](https://github.com/mvz))
- Fix programmatic access [\#417](https://github.com/troessner/reek/pull/417) ([mvz](https://github.com/mvz))

## [v2.0.4](https://github.com/troessner/reek/tree/v2.0.4) (2015-04-07)
[Full Changelog](https://github.com/troessner/reek/compare/v2.0.3...v2.0.4)

**Closed issues:**

- ".reek" file no longer detected as configuration by default [\#425](https://github.com/troessner/reek/issues/425)

**Merged pull requests:**

- Recognise .reek as a valid configuration file [\#426](https://github.com/troessner/reek/pull/426) ([chastell](https://github.com/chastell))

## [v2.0.3](https://github.com/troessner/reek/tree/v2.0.3) (2015-04-06)
[Full Changelog](https://github.com/troessner/reek/compare/v2.0.2...v2.0.3)

**Fixed bugs:**

- Calls to super with parameter and block gives error [\#404](https://github.com/troessner/reek/issues/404)

**Closed issues:**

- Weird return in display\_total\_smell\_count [\#413](https://github.com/troessner/reek/issues/413)

**Merged pull requests:**

- Make NestedIterators handle super with arguments [\#424](https://github.com/troessner/reek/pull/424) ([mvz](https://github.com/mvz))
- Handle shadow block arguments [\#421](https://github.com/troessner/reek/pull/421) ([mvz](https://github.com/mvz))
- Unify recorded references to lvar and lvasgn [\#419](https://github.com/troessner/reek/pull/419) ([mvz](https://github.com/mvz))
- Tinycleanup [\#415](https://github.com/troessner/reek/pull/415) ([chastell](https://github.com/chastell))
- Allow all formatters to support -U \(wiki links\) [\#411](https://github.com/troessner/reek/pull/411) ([CoralineAda](https://github.com/CoralineAda))
- Fix punctuation \(reeks -\> reek's\) [\#410](https://github.com/troessner/reek/pull/410) ([andyw8](https://github.com/andyw8))

## [v2.0.2](https://github.com/troessner/reek/tree/v2.0.2) (2015-03-15)
[Full Changelog](https://github.com/troessner/reek/compare/v2.0.1...v2.0.2)

**Fixed bugs:**

- Document reek internals [\#407](https://github.com/troessner/reek/issues/407)

**Merged pull requests:**

- Fix version command. [\#405](https://github.com/troessner/reek/pull/405) ([troessner](https://github.com/troessner))
- Rake task: drop the no longer supported --quiet option [\#403](https://github.com/troessner/reek/pull/403) ([chastell](https://github.com/chastell))
- Merge `Sniffer` with `Examiner` and refactor `Examiner`. [\#400](https://github.com/troessner/reek/pull/400) ([troessner](https://github.com/troessner))

## [v2.0.1](https://github.com/troessner/reek/tree/v2.0.1) (2015-03-03)
[Full Changelog](https://github.com/troessner/reek/compare/v2.0.0...v2.0.1)

**Fixed bugs:**

- Is anyone using the Cucumber annotations? [\#373](https://github.com/troessner/reek/issues/373)
- false positive on NestedIterators with begin/rescue [\#268](https://github.com/troessner/reek/issues/268)

**Closed issues:**

- Always emit newline at end of output [\#390](https://github.com/troessner/reek/issues/390)
- reek 2 release notes [\#385](https://github.com/troessner/reek/issues/385)
- Update README after 372 [\#383](https://github.com/troessner/reek/issues/383)
- Reek 2 final spurt: release notes and things left to do [\#365](https://github.com/troessner/reek/issues/365)
- Special treatment for utility methods that only raise? [\#181](https://github.com/troessner/reek/issues/181)

**Merged pull requests:**

- Adds JSON output format [\#402](https://github.com/troessner/reek/pull/402) ([leonelgalan](https://github.com/leonelgalan))
- Rename `CodeParser` to `TreeWalker`. [\#399](https://github.com/troessner/reek/pull/399) ([troessner](https://github.com/troessner))
- Only install byebug where it compiles [\#398](https://github.com/troessner/reek/pull/398) ([mvz](https://github.com/mvz))
- Escape Regexp-like Strings on CodeContext matches [\#397](https://github.com/troessner/reek/pull/397) ([chastell](https://github.com/chastell))
- Refactor and comment CodeContext and CodeParser. [\#396](https://github.com/troessner/reek/pull/396) ([troessner](https://github.com/troessner))
- Add contributors to README. [\#394](https://github.com/troessner/reek/pull/394) ([troessner](https://github.com/troessner))
- Refactor smell specs. [\#393](https://github.com/troessner/reek/pull/393) ([troessner](https://github.com/troessner))
- If there is any output, make sure it ends with a newline [\#392](https://github.com/troessner/reek/pull/392) ([mvz](https://github.com/mvz))
- Remove cucumber annotations [\#391](https://github.com/troessner/reek/pull/391) ([mvz](https://github.com/mvz))
- Support more Rubies [\#389](https://github.com/troessner/reek/pull/389) ([mvz](https://github.com/mvz))
- Refactor smells module. [\#388](https://github.com/troessner/reek/pull/388) ([troessner](https://github.com/troessner))
- Update to RuboCop 0.29 [\#387](https://github.com/troessner/reek/pull/387) ([mvz](https://github.com/mvz))
- Remove deprecated API for Examiner. [\#386](https://github.com/troessner/reek/pull/386) ([troessner](https://github.com/troessner))
- Correct output format options shown in README [\#384](https://github.com/troessner/reek/pull/384) ([mvz](https://github.com/mvz))
- Document Modules [\#354](https://github.com/troessner/reek/pull/354) ([mvz](https://github.com/mvz))

## [v2.0.0](https://github.com/troessner/reek/tree/v2.0.0) (2015-02-09)
[Full Changelog](https://github.com/troessner/reek/compare/v1.6.6...v2.0.0)

**Fixed bugs:**

- Clean up reek\_of/smell\_of matchers [\#319](https://github.com/troessner/reek/issues/319)

## [v1.6.6](https://github.com/troessner/reek/tree/v1.6.6) (2015-02-09)
[Full Changelog](https://github.com/troessner/reek/compare/v1.6.5...v1.6.6)

**Closed issues:**

- Passing a block to super -- versions \>= 1.5.0 [\#379](https://github.com/troessner/reek/issues/379)

**Merged pull requests:**

- Fix generating HTML report [\#382](https://github.com/troessner/reek/pull/382) ([guilhermesimoes](https://github.com/guilhermesimoes))
- Simplify finding smell detector class [\#381](https://github.com/troessner/reek/pull/381) ([mvz](https://github.com/mvz))
- Replace "smell\_of" with "reek\_of". [\#371](https://github.com/troessner/reek/pull/371) ([troessner](https://github.com/troessner))

## [v1.6.5](https://github.com/troessner/reek/tree/v1.6.5) (2015-02-08)
[Full Changelog](https://github.com/troessner/reek/compare/v1.6.4...v1.6.5)

**Fixed bugs:**

- Clean up/organize command line options [\#254](https://github.com/troessner/reek/issues/254)

**Closed issues:**

- Gemnasium reports outdated dependencies [\#375](https://github.com/troessner/reek/issues/375)

**Merged pull requests:**

- Make NestedIterator not break when iterator is called on super. [\#380](https://github.com/troessner/reek/pull/380) ([mvz](https://github.com/mvz))
- Fix YAML export on JRuby [\#378](https://github.com/troessner/reek/pull/378) ([mvz](https://github.com/mvz))
- Make Travis CI run build on JRuby 9000 [\#377](https://github.com/troessner/reek/pull/377) ([mvz](https://github.com/mvz))
- Update dependencies. [\#376](https://github.com/troessner/reek/pull/376) ([troessner](https://github.com/troessner))
- Re-organize command line options [\#372](https://github.com/troessner/reek/pull/372) ([mvz](https://github.com/mvz))

## [v1.6.4](https://github.com/troessner/reek/tree/v1.6.4) (2015-01-21)
[Full Changelog](https://github.com/troessner/reek/compare/v1.6.3...v1.6.4)

**Implemented enhancements:**

- Support Ruby 2.2 [\#357](https://github.com/troessner/reek/issues/357)

**Fixed bugs:**

- Re-visit reek task [\#326](https://github.com/troessner/reek/issues/326)

**Merged pull requests:**

- Fix for running reek on a build server [\#374](https://github.com/troessner/reek/pull/374) ([maser](https://github.com/maser))
- Force use of Psych for YAML serialization [\#370](https://github.com/troessner/reek/pull/370) ([mvz](https://github.com/mvz))
- Refactor SmellRepository. [\#369](https://github.com/troessner/reek/pull/369) ([troessner](https://github.com/troessner))
- Make NestedIterator not break if iterator is called on super [\#367](https://github.com/troessner/reek/pull/367) ([marcofognog](https://github.com/marcofognog))
- Revise rake task. [\#362](https://github.com/troessner/reek/pull/362) ([troessner](https://github.com/troessner))

## [v1.6.3](https://github.com/troessner/reek/tree/v1.6.3) (2015-01-15)
[Full Changelog](https://github.com/troessner/reek/compare/v1.6.2...v1.6.3)

**Merged pull requests:**

- Support Ruby 2.2 [\#358](https://github.com/troessner/reek/pull/358) ([mvz](https://github.com/mvz))

## [v1.6.2](https://github.com/troessner/reek/tree/v1.6.2) (2015-01-13)
[Full Changelog](https://github.com/troessner/reek/compare/v1.6.1...v1.6.2)

**Implemented enhancements:**

- Allow more fine grained code context [\#294](https://github.com/troessner/reek/issues/294)
- Default to running on all files [\#222](https://github.com/troessner/reek/issues/222)

**Fixed bugs:**

- Reek 2 - what would you like to see in it? [\#306](https://github.com/troessner/reek/issues/306)

**Merged pull requests:**

- Do not provide -c option if no config file is found [\#368](https://github.com/troessner/reek/pull/368) ([mvz](https://github.com/mvz))
- Prefer pry-byebug in specs and features. [\#366](https://github.com/troessner/reek/pull/366) ([troessner](https://github.com/troessner))
- Fix unparser issue with ruby 1.9.3. by pinning unparser to 0.1.16. [\#364](https://github.com/troessner/reek/pull/364) ([troessner](https://github.com/troessner))
- Run on working directory when no source is given. [\#363](https://github.com/troessner/reek/pull/363) ([troessner](https://github.com/troessner))
- Add integration test for configuration loading. [\#359](https://github.com/troessner/reek/pull/359) ([troessner](https://github.com/troessner))

## [v1.6.1](https://github.com/troessner/reek/tree/v1.6.1) (2014-12-30)
[Full Changelog](https://github.com/troessner/reek/compare/v1.6.0...v1.6.1)

**Implemented enhancements:**

- Improve YAML output [\#313](https://github.com/troessner/reek/issues/313)

**Merged pull requests:**

- Provide alias for backward compatibility [\#360](https://github.com/troessner/reek/pull/360) ([mvz](https://github.com/mvz))

## [v1.6.0](https://github.com/troessner/reek/tree/v1.6.0) (2014-12-27)
[Full Changelog](https://github.com/troessner/reek/compare/v1.5.1...v1.6.0)

**Implemented enhancements:**

- .reekignore [\#220](https://github.com/troessner/reek/issues/220)

**Fixed bugs:**

- Integrating rubocop in our build process and make it fail on offenses \(or add an exception\) [\#348](https://github.com/troessner/reek/issues/348)
- Move smell\_class and smell\_sub\_class to class level [\#344](https://github.com/troessner/reek/issues/344)
- Rename smell\_class and smell\_sub\_class [\#342](https://github.com/troessner/reek/issues/342)
- Crash when scanning default seeds.rb with reek 1.5.0 [\#336](https://github.com/troessner/reek/issues/336)
- Getting rid of the gazillions of constants for the parameter keys [\#332](https://github.com/troessner/reek/issues/332)
- Getting rid of the class methods "smell\_class" and "smell\_sub\_class" for SmellDetector [\#331](https://github.com/troessner/reek/issues/331)
- Refactoring SmellWarning's initializer [\#322](https://github.com/troessner/reek/issues/322)

**Closed issues:**

- Rethinking configuration in reek [\#351](https://github.com/troessner/reek/issues/351)
- Line length limit [\#347](https://github.com/troessner/reek/issues/347)
- Problems with kw\_args reloaded [\#337](https://github.com/troessner/reek/issues/337)
- Making reek smell-free [\#231](https://github.com/troessner/reek/issues/231)
- Extracting code parser [\#190](https://github.com/troessner/reek/issues/190)

**Merged pull requests:**

- Rethinking configuration. [\#356](https://github.com/troessner/reek/pull/356) ([troessner](https://github.com/troessner))
- \[TASK\] Configure Travis for better build performance [\#355](https://github.com/troessner/reek/pull/355) ([oliverklee](https://github.com/oliverklee))
- Set rubocops line length limit to 100. [\#353](https://github.com/troessner/reek/pull/353) ([troessner](https://github.com/troessner))
- RuboCop setup and cleanup [\#352](https://github.com/troessner/reek/pull/352) ([chastell](https://github.com/chastell))
- Get rid of all smell parameter constants. [\#350](https://github.com/troessner/reek/pull/350) ([troessner](https://github.com/troessner))
- Give smell class and smell sub class better names [\#346](https://github.com/troessner/reek/pull/346) ([troessner](https://github.com/troessner))
- Move smell class and sub class methods to class level [\#345](https://github.com/troessner/reek/pull/345) ([troessner](https://github.com/troessner))
- Handle empty source, with and without comments [\#343](https://github.com/troessner/reek/pull/343) ([mvz](https://github.com/mvz))
- Recognise :casgn scoping and fix ModuleInitialize [\#341](https://github.com/troessner/reek/pull/341) ([chastell](https://github.com/chastell))
- Refactor SmellWarning. [\#328](https://github.com/troessner/reek/pull/328) ([troessner](https://github.com/troessner))
- Make data clump handle anonymous params [\#323](https://github.com/troessner/reek/pull/323) ([mvz](https://github.com/mvz))

## [v1.5.1](https://github.com/troessner/reek/tree/v1.5.1) (2014-12-05)
[Full Changelog](https://github.com/troessner/reek/compare/v1.5.0...v1.5.1)

**Closed issues:**

- RubyGem still supports 1.9.2 but is broken for 1.5.0 [\#334](https://github.com/troessner/reek/issues/334)
- nested\_iterators.rb:65:in `find\_iters': undefined method `find\_nodes' for nil:NilClass \(NoMethodError\) [\#333](https://github.com/troessner/reek/issues/333)
- New version released! [\#329](https://github.com/troessner/reek/issues/329)
- reek with named params \(Racc::ParseError: parse error on value ":" \(tCOLON\)\) [\#307](https://github.com/troessner/reek/issues/307)

**Merged pull requests:**

- Required keyword arguments support [\#340](https://github.com/troessner/reek/pull/340) ([chastell](https://github.com/chastell))
- Handle nil-block in iterators [\#338](https://github.com/troessner/reek/pull/338) ([mvz](https://github.com/mvz))
- Update minimum required Ruby version [\#335](https://github.com/troessner/reek/pull/335) ([mvz](https://github.com/mvz))

## [v1.5.0](https://github.com/troessner/reek/tree/v1.5.0) (2014-12-01)
[Full Changelog](https://github.com/troessner/reek/compare/v1.4.0...v1.5.0)

**Closed issues:**

- The documented reek rspec integration is broken [\#315](https://github.com/troessner/reek/issues/315)
- Revamping our wiki [\#314](https://github.com/troessner/reek/issues/314)
- Add GitHub page for Reek [\#259](https://github.com/troessner/reek/issues/259)
- Add `coveralls` and `codeclimate` badge to the top of our README [\#242](https://github.com/troessner/reek/issues/242)
- Inconsistent Usage Between Rake and CLI [\#221](https://github.com/troessner/reek/issues/221)

**Merged pull requests:**

- Use relative reek path for rake task. [\#325](https://github.com/troessner/reek/pull/325) ([troessner](https://github.com/troessner))
- Introduce smell description [\#324](https://github.com/troessner/reek/pull/324) ([mvz](https://github.com/mvz))
- Refactor SmellWarning. [\#321](https://github.com/troessner/reek/pull/321) ([troessner](https://github.com/troessner))
- Support more rubies [\#320](https://github.com/troessner/reek/pull/320) ([mvz](https://github.com/mvz))
- ModuleInitialize smell [\#318](https://github.com/troessner/reek/pull/318) ([mvz](https://github.com/mvz))
- Remove use of rubygems from env.rb [\#317](https://github.com/troessner/reek/pull/317) ([mvz](https://github.com/mvz))
- Revamp README. [\#316](https://github.com/troessner/reek/pull/316) ([troessner](https://github.com/troessner))
- Parse with parser [\#312](https://github.com/troessner/reek/pull/312) ([mvz](https://github.com/mvz))

## [v1.4.0](https://github.com/troessner/reek/tree/v1.4.0) (2014-11-09)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.8...v1.4.0)

**Implemented enhancements:**

- Be self-documenting [\#302](https://github.com/troessner/reek/issues/302)
- option to execute a single smell detector [\#13](https://github.com/troessner/reek/issues/13)

**Fixed bugs:**

- Clean up set of debuggers [\#295](https://github.com/troessner/reek/issues/295)
- Ruby2 keyword arguments with splat gives UnusedParameters [\#262](https://github.com/troessner/reek/issues/262)
- Underscore treated as uncommunicative parameter name [\#195](https://github.com/troessner/reek/issues/195)

**Closed issues:**

- gem install reek fails with RDoc parser error in 1.9.3 [\#291](https://github.com/troessner/reek/issues/291)
- Delete some wiki pages [\#290](https://github.com/troessner/reek/issues/290)
- Output summary is red even if there are no warnings [\#287](https://github.com/troessner/reek/issues/287)
- RuboCop? [\#286](https://github.com/troessner/reek/issues/286)
- reek detects calls to `self.class` as DuplicateMethodCall [\#284](https://github.com/troessner/reek/issues/284)
- Update and fix reek matcher [\#282](https://github.com/troessner/reek/issues/282)
- Remove link to mailing list on Wiki page [\#281](https://github.com/troessner/reek/issues/281)
- Api versions marked as UncommunicativeModuleName [\#271](https://github.com/troessner/reek/issues/271)
- Use RSpec 3 [\#266](https://github.com/troessner/reek/issues/266)

**Merged pull requests:**

- Generate the right wiki links. [\#311](https://github.com/troessner/reek/pull/311) ([troessner](https://github.com/troessner))
- Simplify NestedIterators detector [\#310](https://github.com/troessner/reek/pull/310) ([mvz](https://github.com/mvz))
- Improve and refactor ControlParameter [\#309](https://github.com/troessner/reek/pull/309) ([mvz](https://github.com/mvz))
- Improve and refactor NilCheck [\#308](https://github.com/troessner/reek/pull/308) ([mvz](https://github.com/mvz))
- Add ultra verbose warning formatter. [\#305](https://github.com/troessner/reek/pull/305) ([troessner](https://github.com/troessner))
- Exclude non-source directories from rdoc. [\#301](https://github.com/troessner/reek/pull/301) ([troessner](https://github.com/troessner))
- Re factor to reek less [\#300](https://github.com/troessner/reek/pull/300) ([aakritigupta](https://github.com/aakritigupta))
- Clean up debugger gems [\#299](https://github.com/troessner/reek/pull/299) ([mvz](https://github.com/mvz))
- Require Ruby 1.9.2 or up [\#298](https://github.com/troessner/reek/pull/298) ([mvz](https://github.com/mvz))
- Start using RuboCop [\#297](https://github.com/troessner/reek/pull/297) ([mvz](https://github.com/mvz))
- Make rake test:quality work [\#296](https://github.com/troessner/reek/pull/296) ([mvz](https://github.com/mvz))
- Clean up cruft from rake tasks [\#293](https://github.com/troessner/reek/pull/293) ([mvz](https://github.com/mvz))
- Stop using FileList to specify RSpec patterns [\#292](https://github.com/troessner/reek/pull/292) ([mvz](https://github.com/mvz))
- Color total warning count depending on number of warnings [\#289](https://github.com/troessner/reek/pull/289) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Changed from erubis to erb [\#288](https://github.com/troessner/reek/pull/288) ([SkuliOskarsson](https://github.com/SkuliOskarsson))
- Added simple HTML output [\#285](https://github.com/troessner/reek/pull/285) ([SkuliOskarsson](https://github.com/SkuliOskarsson))
- Make reek run warning-free [\#283](https://github.com/troessner/reek/pull/283) ([mvz](https://github.com/mvz))
- Refactor Cli::Options [\#279](https://github.com/troessner/reek/pull/279) ([mvz](https://github.com/mvz))
- Update README [\#278](https://github.com/troessner/reek/pull/278) ([mvz](https://github.com/mvz))
- Update gemspec [\#277](https://github.com/troessner/reek/pull/277) ([mvz](https://github.com/mvz))
- Run single detector [\#276](https://github.com/troessner/reek/pull/276) ([mvz](https://github.com/mvz))
- Refactor unused parameters smell detector [\#275](https://github.com/troessner/reek/pull/275) ([mvz](https://github.com/mvz))
- Consider block parameter for DuplicateMethodCall [\#274](https://github.com/troessner/reek/pull/274) ([mvz](https://github.com/mvz))
- Use default Ruby version locally [\#273](https://github.com/troessner/reek/pull/273) ([mvz](https://github.com/mvz))
- Corrects UnusedParameter with keyword arguments with splat [\#272](https://github.com/troessner/reek/pull/272) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Update to RSpec 3 [\#267](https://github.com/troessner/reek/pull/267) ([mvz](https://github.com/mvz))
- Use byebug on MRI 2.0 and up [\#265](https://github.com/troessner/reek/pull/265) ([mvz](https://github.com/mvz))

## [v1.3.8](https://github.com/troessner/reek/tree/v1.3.8) (2014-07-07)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.7...v1.3.8)

**Closed issues:**

- Relax or update ruby2ruby dependency [\#263](https://github.com/troessner/reek/issues/263)
- uninitialized constant Reek::Cli::Options::Rainbow [\#257](https://github.com/troessner/reek/issues/257)

**Merged pull requests:**

- Loosen ruby2ruby dependency [\#264](https://github.com/troessner/reek/pull/264) ([mvz](https://github.com/mvz))
- Update docs badge in README [\#261](https://github.com/troessner/reek/pull/261) ([rrrene](https://github.com/rrrene))
- Specify required Rainbow version as \>= 1.99 [\#258](https://github.com/troessner/reek/pull/258) ([bf4](https://github.com/bf4))
- Avoid duplicate method calls [\#256](https://github.com/troessner/reek/pull/256) ([andyw8](https://github.com/andyw8))

## [v1.3.7](https://github.com/troessner/reek/tree/v1.3.7) (2014-03-25)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.6...v1.3.7)

**Implemented enhancements:**

- Default `-q` switch:  do not show files without any warnings [\#169](https://github.com/troessner/reek/issues/169)
- Bang method without non-bang method [\#51](https://github.com/troessner/reek/issues/51)

**Fixed bugs:**

- Fix local configuration handling for CodeContext? [\#203](https://github.com/troessner/reek/issues/203)
- Bang method without non-bang method [\#51](https://github.com/troessner/reek/issues/51)

**Closed issues:**

- Adding colors to reek's output [\#250](https://github.com/troessner/reek/issues/250)
- Configuration within comments [\#241](https://github.com/troessner/reek/issues/241)
- The ControlParameter detector is inconsistent. [\#177](https://github.com/troessner/reek/issues/177)

**Merged pull requests:**

- Adds the rainbow dependency to the readme [\#255](https://github.com/troessner/reek/pull/255) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Improve statement counting [\#253](https://github.com/troessner/reek/pull/253) ([mvz](https://github.com/mvz))
- Add color to reek's output [\#252](https://github.com/troessner/reek/pull/252) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Small refactorings to remove some code smells. [\#251](https://github.com/troessner/reek/pull/251) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Refactoring of the ControlParameter smell detector [\#249](https://github.com/troessner/reek/pull/249) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Add docs badge to README [\#248](https://github.com/troessner/reek/pull/248) ([rrrene](https://github.com/rrrene))
- Minor refactorings to remove some reek smells. [\#247](https://github.com/troessner/reek/pull/247) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Ignore unused parameters if method calls super in nested context [\#246](https://github.com/troessner/reek/pull/246) ([mvz](https://github.com/mvz))
- Added link to preek \(as requested\) [\#245](https://github.com/troessner/reek/pull/245) ([joenas](https://github.com/joenas))
- Remove HashExtensions [\#244](https://github.com/troessner/reek/pull/244) ([mvz](https://github.com/mvz))
- Only mark parameters uncommunicative if used [\#243](https://github.com/troessner/reek/pull/243) ([mvz](https://github.com/mvz))
- Refactor CLI commands. [\#240](https://github.com/troessner/reek/pull/240) ([troessner](https://github.com/troessner))
- Add Ruby 2.1.0 to .travis.yml [\#239](https://github.com/troessner/reek/pull/239) ([salimane](https://github.com/salimane))
- Don’t mark kwargs as unused [\#237](https://github.com/troessner/reek/pull/237) ([chastell](https://github.com/chastell))

## [v1.3.6](https://github.com/troessner/reek/tree/v1.3.6) (2013-12-29)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.5...v1.3.6)

**Merged pull requests:**

- Prima donna method smell [\#230](https://github.com/troessner/reek/pull/230) ([troessner](https://github.com/troessner))

## [v1.3.5](https://github.com/troessner/reek/tree/v1.3.5) (2013-12-23)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.4...v1.3.5)

**Implemented enhancements:**

- Prioritize files by \# of issues [\#207](https://github.com/troessner/reek/issues/207)
- Disable smell all subclasses via the smell class [\#67](https://github.com/troessner/reek/issues/67)
- DataClump not reported on closely related classes [\#54](https://github.com/troessner/reek/issues/54)
- Temporary Field [\#22](https://github.com/troessner/reek/issues/22)

**Fixed bugs:**

- Runaway Dependencies [\#48](https://github.com/troessner/reek/issues/48)
- Long Method should count nested assignments [\#32](https://github.com/troessner/reek/issues/32)
- Long Method should count nested assignments [\#32](https://github.com/troessner/reek/issues/32)
- Temporary Field [\#22](https://github.com/troessner/reek/issues/22)

**Closed issues:**

- reek hung up [\#234](https://github.com/troessner/reek/issues/234)
- Timeout::Error: execution expired issue [\#223](https://github.com/troessner/reek/issues/223)
- Can't customize UncommunicativeVariableName or UncommunicativeParameterName [\#217](https://github.com/troessner/reek/issues/217)
- Unknown node-type :kwsplat [\#213](https://github.com/troessner/reek/issues/213)
- emacs-compatible line number output [\#206](https://github.com/troessner/reek/issues/206)
- Improve exception handling [\#204](https://github.com/troessner/reek/issues/204)
- reek errors when parsing escape sequence in a method [\#201](https://github.com/troessner/reek/issues/201)
-  reek 1.3.2: Error: unknown arg type :masgn [\#184](https://github.com/troessner/reek/issues/184)

**Merged pull requests:**

- Issue quiet by default [\#238](https://github.com/troessner/reek/pull/238) ([mvz](https://github.com/mvz))
- Improve line numbers CLI options [\#235](https://github.com/troessner/reek/pull/235) ([mvz](https://github.com/mvz))
- Fix spec for uncommunicative-method-name smell. [\#233](https://github.com/troessner/reek/pull/233) ([troessner](https://github.com/troessner))
- Add `pry` gem as development dependency. [\#232](https://github.com/troessner/reek/pull/232) ([troessner](https://github.com/troessner))
- Separate test dev dependencies [\#229](https://github.com/troessner/reek/pull/229) ([bf4](https://github.com/bf4))
- Allow sorting by issue count. [\#228](https://github.com/troessner/reek/pull/228) ([troessner](https://github.com/troessner))
- Force ruby2ruby update. [\#227](https://github.com/troessner/reek/pull/227) ([troessner](https://github.com/troessner))
- Add `debugger` gem. [\#226](https://github.com/troessner/reek/pull/226) ([troessner](https://github.com/troessner))
- Refactor reporting handling as a precondition for sorting output. [\#224](https://github.com/troessner/reek/pull/224) ([troessner](https://github.com/troessner))
- Refactor DuplicateMethodCall smell detector [\#219](https://github.com/troessner/reek/pull/219) ([mvz](https://github.com/mvz))
- Clean up tree\_dresser.rb [\#218](https://github.com/troessner/reek/pull/218) ([mvz](https://github.com/mvz))
- Updating documentaion: Adding information for reek textmate bundle [\#216](https://github.com/troessner/reek/pull/216) ([peeyush1234](https://github.com/peeyush1234))
- Simplify ShouldReek matcher [\#214](https://github.com/troessner/reek/pull/214) ([mvz](https://github.com/mvz))
- Simplify implementation of DataClump [\#212](https://github.com/troessner/reek/pull/212) ([mvz](https://github.com/mvz))
- Improve SmellOfMatcher [\#211](https://github.com/troessner/reek/pull/211) ([mvz](https://github.com/mvz))
- No general exceptions [\#210](https://github.com/troessner/reek/pull/210) ([mvz](https://github.com/mvz))
- Added more robust ControlParameter detection. [\#194](https://github.com/troessner/reek/pull/194) ([gilles-leblanc](https://github.com/gilles-leblanc))

## [v1.3.4](https://github.com/troessner/reek/tree/v1.3.4) (2013-10-14)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.3...v1.3.4)

**Implemented enhancements:**

- Reek fails on ruby 2.0 keyword arguments [\#165](https://github.com/troessner/reek/issues/165)

**Closed issues:**

- Improve Sexp\#deep\_copy [\#202](https://github.com/troessner/reek/issues/202)
- LongMethod is no longer a valid code smell? [\#200](https://github.com/troessner/reek/issues/200)
- performs a nil-check  [\#199](https://github.com/troessner/reek/issues/199)
-  DuplicateMethodCall format.json [\#198](https://github.com/troessner/reek/issues/198)
- do not show those files without any warnings [\#197](https://github.com/troessner/reek/issues/197)
- impossible to run reek without parameters. [\#196](https://github.com/troessner/reek/issues/196)
- Don't add extra slashes to directory names [\#176](https://github.com/troessner/reek/issues/176)
- Default `-n` [\#170](https://github.com/troessner/reek/issues/170)
- `reek` with no arguments should behave as `reek .` [\#155](https://github.com/troessner/reek/issues/155)
- How to override defaults in UncommunicativeVariableName? [\#154](https://github.com/troessner/reek/issues/154)

**Merged pull requests:**

- Add --single-line option for reporting \(github Issue \#206\) [\#208](https://github.com/troessner/reek/pull/208) ([apiology](https://github.com/apiology))
- Improve Sexp\#deep\_copy [\#205](https://github.com/troessner/reek/pull/205) ([mvz](https://github.com/mvz))
- Allow config files to override default config values [\#192](https://github.com/troessner/reek/pull/192) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Added line numbers by default when you run the reek command [\#191](https://github.com/troessner/reek/pull/191) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Added feature to remove extra slash from source path to prevent doubling... [\#189](https://github.com/troessner/reek/pull/189) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Support Ruby 2.0 syntax [\#188](https://github.com/troessner/reek/pull/188) ([mvz](https://github.com/mvz))

## [v1.3.3](https://github.com/troessner/reek/tree/v1.3.3) (2013-08-27)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.2...v1.3.3)

**Implemented enhancements:**

- Need a way to set different thresholds for the same smell [\#36](https://github.com/troessner/reek/issues/36)
- Fail on unnecessary exclusions [\#23](https://github.com/troessner/reek/issues/23)

**Closed issues:**

- Trouble with Rake task and Bundler [\#185](https://github.com/troessner/reek/issues/185)
- Display total warning count [\#175](https://github.com/troessner/reek/issues/175)

**Merged pull requests:**

- Loosen ruby\_parser version dependency [\#187](https://github.com/troessner/reek/pull/187) ([bf4](https://github.com/bf4))
- Added total warning count [\#186](https://github.com/troessner/reek/pull/186) ([gilles-leblanc](https://github.com/gilles-leblanc))
- Replaced deprecated mock and any\_number\_of\_times that were used by RSpec mocks [\#182](https://github.com/troessner/reek/pull/182) ([gilles-leblanc](https://github.com/gilles-leblanc))

## [v1.3.2](https://github.com/troessner/reek/tree/v1.3.2) (2013-08-09)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3.1...v1.3.2)

**Implemented enhancements:**

- reek doesn't see .reek in my project's toplevel directory [\#150](https://github.com/troessner/reek/issues/150)
- exceptions.reek uses different names than error messages [\#95](https://github.com/troessner/reek/issues/95)
- Nested Iterator warns on non-iterating blocks   [\#83](https://github.com/troessner/reek/issues/83)
- Feature envy for excessive constant usage [\#81](https://github.com/troessner/reek/issues/81)
- TemplateMethod [\#52](https://github.com/troessner/reek/issues/52)
- Core extension [\#46](https://github.com/troessner/reek/issues/46)
- Validate contents of config files [\#42](https://github.com/troessner/reek/issues/42)
- smell severity [\#30](https://github.com/troessner/reek/issues/30)
- Adapters are different from domain code [\#20](https://github.com/troessner/reek/issues/20)
- Feature Envy for blocks and code fragments [\#15](https://github.com/troessner/reek/issues/15)
- Nil Check [\#8](https://github.com/troessner/reek/issues/8)

**Fixed bugs:**

- UnusedParameters doesn't take `super` into account [\#135](https://github.com/troessner/reek/issues/135)
- TemplateMethod [\#52](https://github.com/troessner/reek/issues/52)
- Core extension [\#46](https://github.com/troessner/reek/issues/46)
- Adapters are different from domain code [\#20](https://github.com/troessner/reek/issues/20)
- Feature Envy for blocks and code fragments [\#15](https://github.com/troessner/reek/issues/15)
- Nil Check [\#8](https://github.com/troessner/reek/issues/8)

**Closed issues:**

- Broken links in readme and project description [\#180](https://github.com/troessner/reek/issues/180)
- Advised to update json dependency [\#168](https://github.com/troessner/reek/issues/168)
- bundle exec rake test: 8/30 tests fail \(Windows\) [\#166](https://github.com/troessner/reek/issues/166)
- rspec test failures \(Windows\) [\#163](https://github.com/troessner/reek/issues/163)
- Mac OS X: Failing tests [\#160](https://github.com/troessner/reek/issues/160)
- Recommend standard name for reek configuration files [\#159](https://github.com/troessner/reek/issues/159)
- Ability to specify command line options in defaults.reek [\#156](https://github.com/troessner/reek/issues/156)
- Still links to the old project in rdoc.info [\#153](https://github.com/troessner/reek/issues/153)
- Mac OS X: reek binary is not being added to PATH [\#152](https://github.com/troessner/reek/issues/152)
- Bug: `doesn't depend on instance state \(UtilityFunction\)` complains about my module methods [\#151](https://github.com/troessner/reek/issues/151)
- Hide "0 warnings" message [\#149](https://github.com/troessner/reek/issues/149)
- How do I turn on line numbers in my defaults.reek? [\#148](https://github.com/troessner/reek/issues/148)
- Vim plugin [\#140](https://github.com/troessner/reek/issues/140)
- Reek reports TooManyStatements, but the actual smell is LongMethod [\#139](https://github.com/troessner/reek/issues/139)
- Update ruby specified in .rvmrc from 1.8.7 to 1.9.3 [\#138](https://github.com/troessner/reek/issues/138)
- Add ability to suppress an individual warning [\#137](https://github.com/troessner/reek/issues/137)
- nil check gives a different line number output when using -n flag [\#132](https://github.com/troessner/reek/issues/132)
- Know how to solve the smells [\#128](https://github.com/troessner/reek/issues/128)
- Dependency problems with flog and flay [\#114](https://github.com/troessner/reek/issues/114)

**Merged pull requests:**

- Fix dup in code example [\#179](https://github.com/troessner/reek/pull/179) ([mrclmrvn](https://github.com/mrclmrvn))
- Allow duplicate calls to variable-like methods [\#178](https://github.com/troessner/reek/pull/178) ([mvz](https://github.com/mvz))
- Improve NilCheck specs [\#174](https://github.com/troessner/reek/pull/174) ([mvz](https://github.com/mvz))
- Improve SmellOfMatcher [\#173](https://github.com/troessner/reek/pull/173) ([mvz](https://github.com/mvz))
- Remove RSpec option settings [\#172](https://github.com/troessner/reek/pull/172) ([mvz](https://github.com/mvz))
- Make combination of -n and -q options work [\#171](https://github.com/troessner/reek/pull/171) ([mvz](https://github.com/mvz))
- Improve NestedIterators smell detector [\#164](https://github.com/troessner/reek/pull/164) ([mvz](https://github.com/mvz))
- Remove Manifest.txt and its specs [\#162](https://github.com/troessner/reek/pull/162) ([mvz](https://github.com/mvz))
- Clean up code [\#158](https://github.com/troessner/reek/pull/158) ([mvz](https://github.com/mvz))
- Allow config files named `.reek` [\#157](https://github.com/troessner/reek/pull/157) ([mvz](https://github.com/mvz))
- Update Gemfile to use SSL when connecting to rubygems [\#147](https://github.com/troessner/reek/pull/147) ([ghost](https://github.com/ghost))
- Fix smell classes [\#145](https://github.com/troessner/reek/pull/145) ([mvz](https://github.com/mvz))
- Improve default config creation [\#144](https://github.com/troessner/reek/pull/144) ([mvz](https://github.com/mvz))
- Four clean-ups [\#143](https://github.com/troessner/reek/pull/143) ([mvz](https://github.com/mvz))
- Support marking unused parameters by prefixing them with \_ [\#142](https://github.com/troessner/reek/pull/142) ([snusnu](https://github.com/snusnu))
- Make UnusedParameters correctly handle super [\#136](https://github.com/troessner/reek/pull/136) ([mvz](https://github.com/mvz))
- Fixed nil-checker output with -n flag [\#133](https://github.com/troessner/reek/pull/133) ([EmilRehnberg](https://github.com/EmilRehnberg))

## [v1.3.1](https://github.com/troessner/reek/tree/v1.3.1) (2013-02-01)
[Full Changelog](https://github.com/troessner/reek/compare/v1.3...v1.3.1)

**Closed issues:**

- Command line option to output line numbers \(for editor integration\) [\#117](https://github.com/troessner/reek/issues/117)

**Merged pull requests:**

- Add smell for nil checks [\#131](https://github.com/troessner/reek/pull/131) ([EmilRehnberg](https://github.com/EmilRehnberg))
- Updated dependencies to use ruby2ruby 2.0.2 and ruby\_parser 3.1.1 [\#130](https://github.com/troessner/reek/pull/130) ([geoffharcourt](https://github.com/geoffharcourt))
- Added command-line option for printing line numbers with the smell lines... [\#129](https://github.com/troessner/reek/pull/129) ([EmilRehnberg](https://github.com/EmilRehnberg))

## [v1.3](https://github.com/troessner/reek/tree/v1.3) (2013-01-19)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.13...v1.3)

**Implemented enhancements:**

- UncommunicativeName: 'accept' should be called 'allow' [\#40](https://github.com/troessner/reek/issues/40)
- Large Module [\#12](https://github.com/troessner/reek/issues/12)
- Unused Parameter [\#7](https://github.com/troessner/reek/issues/7)

**Fixed bugs:**

- Large Module [\#12](https://github.com/troessner/reek/issues/12)
- Unused Parameter [\#7](https://github.com/troessner/reek/issues/7)

**Closed issues:**

- Error on Sexp [\#125](https://github.com/troessner/reek/issues/125)

**Merged pull requests:**

- Improve generated default settings list [\#134](https://github.com/troessner/reek/pull/134) ([mvz](https://github.com/mvz))
- Improve unused parameters [\#127](https://github.com/troessner/reek/pull/127) ([mvz](https://github.com/mvz))
- Updated Manifest and reek.gemspec [\#126](https://github.com/troessner/reek/pull/126) ([EmilRehnberg](https://github.com/EmilRehnberg))
- Pass tests for spec/gem [\#124](https://github.com/troessner/reek/pull/124) ([EmilRehnberg](https://github.com/EmilRehnberg))
- Unused parameter smell added [\#123](https://github.com/troessner/reek/pull/123) ([EmilRehnberg](https://github.com/EmilRehnberg))
- Check entire reek output at once [\#121](https://github.com/troessner/reek/pull/121) ([mvz](https://github.com/mvz))

## [v1.2.13](https://github.com/troessner/reek/tree/v1.2.13) (2012-12-07)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.12...v1.2.13)

**Implemented enhancements:**

- HTML Report [\#103](https://github.com/troessner/reek/issues/103)

**Fixed bugs:**

- Remove obsolete branches [\#111](https://github.com/troessner/reek/issues/111)
- SimulatedPolymorphism options ignored [\#92](https://github.com/troessner/reek/issues/92)
- Split the rspec matchers into a separate gem [\#86](https://github.com/troessner/reek/issues/86)
- Class methods defined in "class \<\< self; end" not recognised as such [\#29](https://github.com/troessner/reek/issues/29)

**Closed issues:**

- Update to new version of ruby-parser [\#116](https://github.com/troessner/reek/issues/116)
- should\_not reek matcher not working [\#113](https://github.com/troessner/reek/issues/113)
- Rake task integration fails [\#110](https://github.com/troessner/reek/issues/110)
- Symbols created with string syntax causes RuntimeError [\#109](https://github.com/troessner/reek/issues/109)
- Can't redirect output with multiple files [\#106](https://github.com/troessner/reek/issues/106)

**Merged pull requests:**

- undefined method `chr' on an instance of String on Rubinius [\#118](https://github.com/troessner/reek/pull/118) ([petrjanda](https://github.com/petrjanda))
- Remove extra comma from array of smells and fix indentation [\#115](https://github.com/troessner/reek/pull/115) ([makaroni4](https://github.com/makaroni4))
- Config deprecated, use RbConfig [\#108](https://github.com/troessner/reek/pull/108) ([miketheman](https://github.com/miketheman))

## [v1.2.12](https://github.com/troessner/reek/tree/v1.2.12) (2012-06-09)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.11...v1.2.12)

**Merged pull requests:**

- Dynamically depend on best available parser [\#107](https://github.com/troessner/reek/pull/107) ([mvz](https://github.com/mvz))

## [v1.2.11](https://github.com/troessner/reek/tree/v1.2.11) (2012-06-08)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.10...v1.2.11)

**Implemented enhancements:**

- RSpec 2 support [\#61](https://github.com/troessner/reek/issues/61)

**Fixed bugs:**

- Reek fails on \(some\) Ruby 1.9 hash syntax  [\#94](https://github.com/troessner/reek/issues/94)
- reopening a class  : irresponsible module [\#71](https://github.com/troessner/reek/issues/71)
- Can't be a UtilityFunction when there's no enclosing module [\#21](https://github.com/troessner/reek/issues/21)

**Merged pull requests:**

- Use ripper\_ruby\_parser on Ruby 1.9.3 and up [\#102](https://github.com/troessner/reek/pull/102) ([mvz](https://github.com/mvz))

## [v1.2.10](https://github.com/troessner/reek/tree/v1.2.10) (2012-06-06)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.9...v1.2.10)

**Fixed bugs:**

- Undefined method `sexp\_type [\#101](https://github.com/troessner/reek/issues/101)

## [v1.2.9](https://github.com/troessner/reek/tree/v1.2.9) (2012-06-06)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.8...v1.2.9)

**Implemented enhancements:**

- Underscore treated as uncommunicative name [\#93](https://github.com/troessner/reek/issues/93)
- can't find input file in rubinius [\#79](https://github.com/troessner/reek/issues/79)
- Private Method [\#63](https://github.com/troessner/reek/issues/63)
- Configure reek per-file, not per-smell [\#37](https://github.com/troessner/reek/issues/37)
- Large Class should not count added methods from validations / associations in Rails [\#24](https://github.com/troessner/reek/issues/24)

**Fixed bugs:**

- Reek breaks with ruby2ruby 1.3.1 [\#88](https://github.com/troessner/reek/issues/88)
- Create an IRC channel for reek? [\#85](https://github.com/troessner/reek/issues/85)
- UncommunicativeName configuration options should be better explained in the wiki [\#75](https://github.com/troessner/reek/issues/75)
- reek does not parse 1.9 new hash syntax [\#69](https://github.com/troessner/reek/issues/69)
- reek doesn't work with jeweler [\#65](https://github.com/troessner/reek/issues/65)
- Private Method [\#63](https://github.com/troessner/reek/issues/63)

**Closed issues:**

- Where did wiki/docs go?  [\#104](https://github.com/troessner/reek/issues/104)
- reek matcher ignores configuration [\#89](https://github.com/troessner/reek/issues/89)
- Reek can't exclude a method in a module? [\#87](https://github.com/troessner/reek/issues/87)
- Add a Gemfile and .rvmrc [\#84](https://github.com/troessner/reek/issues/84)
- Unnecessary duplication warning [\#80](https://github.com/troessner/reek/issues/80)
- reek should no analyze code found after \_\_END\_\_ [\#73](https://github.com/troessner/reek/issues/73)
- Errors on Mac OSX 10.5.8 Ruby 1.9.1 [\#59](https://github.com/troessner/reek/issues/59)

**Merged pull requests:**

- Fix old links pointing to Kevin Rutherfords original github reek repository  [\#105](https://github.com/troessner/reek/pull/105) ([andywenk](https://github.com/andywenk))
- Smell detector for initialize in modules + less smells in smell detectors [\#100](https://github.com/troessner/reek/pull/100) ([Vasfed](https://github.com/Vasfed))
- Modernize gemspec [\#97](https://github.com/troessner/reek/pull/97) ([mvz](https://github.com/mvz))
- Make specs pass with Ruby2Ruby 1.3.1. [\#96](https://github.com/troessner/reek/pull/96) ([mvz](https://github.com/mvz))
- Update README to explain that Reek can't parse new Ruby 1.9 hashes [\#91](https://github.com/troessner/reek/pull/91) ([jcf](https://github.com/jcf))
- reek matcher ignores configuration [\#90](https://github.com/troessner/reek/pull/90) ([jhwist](https://github.com/jhwist))
- Adds Rake support for Bundler. [\#77](https://github.com/troessner/reek/pull/77) ([whittle](https://github.com/whittle))

## [v1.2.8](https://github.com/troessner/reek/tree/v1.2.8) (2010-04-26)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.7.3...v1.2.8)

## [v1.2.7.3](https://github.com/troessner/reek/tree/v1.2.7.3) (2010-03-29)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.7.2...v1.2.7.3)

## [v1.2.7.2](https://github.com/troessner/reek/tree/v1.2.7.2) (2010-03-05)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.7.1...v1.2.7.2)

## [v1.2.7.1](https://github.com/troessner/reek/tree/v1.2.7.1) (2010-02-03)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.7...v1.2.7.1)

## [v1.2.7](https://github.com/troessner/reek/tree/v1.2.7) (2010-02-01)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.6...v1.2.7)

## [v1.2.6](https://github.com/troessner/reek/tree/v1.2.6) (2009-11-28)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.5...v1.2.6)

## [v1.2.5](https://github.com/troessner/reek/tree/v1.2.5) (2009-11-19)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.4...v1.2.5)

## [v1.2.4](https://github.com/troessner/reek/tree/v1.2.4) (2009-11-17)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.3...v1.2.4)

## [v1.2.3](https://github.com/troessner/reek/tree/v1.2.3) (2009-11-02)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.2...v1.2.3)

## [v1.2.2](https://github.com/troessner/reek/tree/v1.2.2) (2009-10-06)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.1...v1.2.2)

## [v1.2.1](https://github.com/troessner/reek/tree/v1.2.1) (2009-10-03)
[Full Changelog](https://github.com/troessner/reek/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/troessner/reek/tree/v1.2.0) (2009-09-20)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.16...v1.2.0)

## [v1.1.3.16](https://github.com/troessner/reek/tree/v1.1.3.16) (2009-09-19)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.15...v1.1.3.16)

## [v1.1.3.15](https://github.com/troessner/reek/tree/v1.1.3.15) (2009-09-03)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.14...v1.1.3.15)

## [v1.1.3.14](https://github.com/troessner/reek/tree/v1.1.3.14) (2009-08-20)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.13...v1.1.3.14)

## [v1.1.3.13](https://github.com/troessner/reek/tree/v1.1.3.13) (2009-07-26)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.12...v1.1.3.13)

## [v1.1.3.12](https://github.com/troessner/reek/tree/v1.1.3.12) (2009-07-25)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.11...v1.1.3.12)

## [v1.1.3.11](https://github.com/troessner/reek/tree/v1.1.3.11) (2009-07-23)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.10...v1.1.3.11)

## [v1.1.3.10](https://github.com/troessner/reek/tree/v1.1.3.10) (2009-07-15)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.9...v1.1.3.10)

## [v1.1.3.9](https://github.com/troessner/reek/tree/v1.1.3.9) (2009-07-06)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.8...v1.1.3.9)

## [v1.1.3.8](https://github.com/troessner/reek/tree/v1.1.3.8) (2009-07-06)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.7...v1.1.3.8)

## [v1.1.3.7](https://github.com/troessner/reek/tree/v1.1.3.7) (2009-07-02)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.6...v1.1.3.7)

## [v1.1.3.6](https://github.com/troessner/reek/tree/v1.1.3.6) (2009-06-30)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.5...v1.1.3.6)

## [v1.1.3.5](https://github.com/troessner/reek/tree/v1.1.3.5) (2009-06-29)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.4...v1.1.3.5)

## [v1.1.3.4](https://github.com/troessner/reek/tree/v1.1.3.4) (2009-06-19)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.3...v1.1.3.4)

## [v1.1.3.3](https://github.com/troessner/reek/tree/v1.1.3.3) (2009-06-17)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.2...v1.1.3.3)

## [v1.1.3.2](https://github.com/troessner/reek/tree/v1.1.3.2) (2009-06-13)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3.1...v1.1.3.2)

## [v1.1.3.1](https://github.com/troessner/reek/tree/v1.1.3.1) (2009-06-04)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.3...v1.1.3.1)

## [v1.1.3](https://github.com/troessner/reek/tree/v1.1.3) (2009-05-19)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.2.1...v1.1.3)

## [v1.1.2.1](https://github.com/troessner/reek/tree/v1.1.2.1) (2009-05-18)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.2...v1.1.2.1)

## [v1.1.2](https://github.com/troessner/reek/tree/v1.1.2) (2009-05-18)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.1...v1.1.2)

## [v1.1.1](https://github.com/troessner/reek/tree/v1.1.1) (2009-05-08)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.0.1...v1.1.1)

## [v1.1.0.1](https://github.com/troessner/reek/tree/v1.1.0.1) (2009-04-11)
[Full Changelog](https://github.com/troessner/reek/compare/v1.1.0...v1.1.0.1)

## [v1.1.0](https://github.com/troessner/reek/tree/v1.1.0) (2009-04-10)
[Full Changelog](https://github.com/troessner/reek/compare/v1.0.1...v1.1.0)

## [v1.0.1](https://github.com/troessner/reek/tree/v1.0.1) (2009-04-06)
[Full Changelog](https://github.com/troessner/reek/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/troessner/reek/tree/v1.0.0) (2009-04-05)
[Full Changelog](https://github.com/troessner/reek/compare/v0.3.1.6...v1.0.0)

## [v0.3.1.6](https://github.com/troessner/reek/tree/v0.3.1.6) (2009-03-31)
[Full Changelog](https://github.com/troessner/reek/compare/v0.3.1.5...v0.3.1.6)

## [v0.3.1.5](https://github.com/troessner/reek/tree/v0.3.1.5) (2009-03-31)
[Full Changelog](https://github.com/troessner/reek/compare/v0.3.1.4...v0.3.1.5)

## [v0.3.1.4](https://github.com/troessner/reek/tree/v0.3.1.4) (2009-03-30)
[Full Changelog](https://github.com/troessner/reek/compare/v0.3.1.3...v0.3.1.4)

## [v0.3.1.3](https://github.com/troessner/reek/tree/v0.3.1.3) (2009-03-29)
[Full Changelog](https://github.com/troessner/reek/compare/v0.3.1.2...v0.3.1.3)

## [v0.3.1.2](https://github.com/troessner/reek/tree/v0.3.1.2) (2009-03-22)
[Full Changelog](https://github.com/troessner/reek/compare/v0.3.0...v0.3.1.2)

## [v0.3.0](https://github.com/troessner/reek/tree/v0.3.0) (2008-11-02)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*