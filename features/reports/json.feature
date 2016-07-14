Feature: Report smells using simple JSON layout
  In order to parse Reek's output simply and consistently, simply
  output a list of smells in JSON.

  Scenario: output is empty when there are no smells
    Given a directory called 'clean_files' containing some clean files
    When I run reek --format json clean_files
    Then it succeeds
    And it reports this JSON:
    """
    []
    """

  Scenario: Indicate smells and print them as JSON when using files
    Given a smelly file called 'smelly.rb'
    When I run reek --format json smelly.rb
    Then the exit status indicates smells
    And it reports this JSON:
      """
      [
          {
              "smell_type": "DuplicateMethodCall",
              "source": "smelly.rb",
              "context": "Smelly#m",
              "lines": [ 4, 5 ],
              "message": "calls @foo.bar 2 times",
              "name": "@foo.bar",
              "wiki_link": "https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md",
              "count": 2
          },
          {
              "smell_type": "DuplicateMethodCall",
              "source": "smelly.rb",
              "context": "Smelly#m",
              "lines": [ 4, 5 ],
              "message": "calls puts @foo.bar 2 times",
              "name": "puts @foo.bar",
              "wiki_link": "https://github.com/troessner/reek/blob/master/docs/Duplicate-Method-Call.md",
              "count": 2
          },
          {
              "context": "Smelly",
              "lines": [2],
              "message": "assumes too much for instance variable @foo",
              "smell_type": "InstanceVariableAssumption",
              "source": "smelly.rb",
              "assumptions": ["@foo"],
              "wiki_link": "https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md"
          },
          {
              "smell_type": "UncommunicativeMethodName",
              "source": "smelly.rb",
              "context": "Smelly#m",
              "lines": [ 3 ],
              "message": "has the name 'm'",
              "wiki_link": "https://github.com/troessner/reek/blob/master/docs/Uncommunicative-Method-Name.md",
              "name": "m"
          }
      ]
      """

  Scenario: Indicate smells and print them as JSON when using STDIN
    When I pass "class Turn; end" to reek --format json
    Then the exit status indicates smells
    And it reports this JSON:
      """
      [
          {
              "smell_type": "IrresponsibleModule",
              "source": "STDIN",
              "context": "Turn",
              "lines": [
                  1
              ],
              "message": "has no descriptive comment",
              "wiki_link": "https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md",
              "name": "Turn"
          }
      ]
      """
