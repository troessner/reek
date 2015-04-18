Feature: Reek can be controlled using command-line options
  In order to change reek's default behaviour
  As a developer
  I want to supply options on the command line

  Scenario: return non-zero status on bad option
    When I run reek --no-such-option
    Then the exit status indicates an error
    And it reports the error "Error: invalid option: --no-such-option"
    And there is no output on stdout

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
      reek -s lib
      cat my_class.rb | reek

      See https://wiki.github.com/troessner/reek for detailed help.

      Configuration:
          -c, --config FILE                Read configuration options from FILE
              --smell SMELL                Detect smell SMELL (default: all enabled smells)

      Report format:
          -f, --format FORMAT              Report smells in the given format:
                                             html
                                             text (default)
                                             yaml
                                             json
                                             xml

      Text format options:
              --[no-]color                 Use colors for the output (default: true)
          -V, --[no-]empty-headings        Show headings for smell-free source files (default: false)
          -U, --[no-]wiki-links            Show link to related wiki page for each smell (default: false)
          -n, --[no-]line-numbers          Show line numbers in the output (default: true)
          -s, --single-line                Show location in editor-compatible single-line-per-smell format
              --sort-by SORTING            Sort reported files by the given criterium:
                                             smelliness ("smelliest" files first)
                                             none (default - output in processing order)

      Utility options:
          -h, --help                       Show this message
          -v, --version                    Show version
      """
