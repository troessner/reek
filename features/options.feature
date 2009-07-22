@options
Feature: Reek can be controlled using command-line options
  In order to change reek's default behaviour
  As a developer
  I want to supply options on the command line

  Scenario: return non-zero status on bad option
    When I run reek --no-such-option
    Then it fails with exit status 1
    And it reports the error "Error: invalid option: --no-such-option"

  Scenario: return non-zero status on missing argument
    When I run reek -f
    Then it fails with exit status 1
    And it reports the error "Error: missing argument: -f"

  Scenario: display the current version number
    When I run reek --version
    Then it succeeds
    And it reports the current version

  Scenario: display the help information
    When I run reek --help
    Then it succeeds
    And it reports:
      """
      Usage: reek [options] [files]

      Examples:

      reek lib/*.rb
      reek -q -a lib
      cat my_class.rb | reek

      See http://wiki.github.com/kevinrutherford/reek for detailed help.

      Common options:
          -h, --help                       Show this message
          -v, --version                    Show version


      Report formatting:
          -a, --[no-]show-all              Show all smells, including those masked by config settings
          -q, --quiet                      Suppress headings for smell-free source files
          -f, --format FORMAT              Specify the format of smell warnings
          -c, --context-first              Sort by context; sets the format string to "%m%c %w (%s)"
          -s, --smell-first                Sort by smell; sets the format string to "%m[%s] %c %w"

      """
