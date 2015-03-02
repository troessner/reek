Feature: Report smells using simple JSON layout
  In order to parse reek's output simply and consistently, simply
  output a list of smells in JSON.

  Scenario: output is empty when there are no smells
    When I run reek --format json spec/samples/three_clean_files
    Then it succeeds
    And it reports this JSON:
    """
    []
    """

  Scenario: Indicate smells and print them as JSON when using files
    When I run reek --format json spec/samples/standard_smelly/minimal_dirty.rb
    Then the exit status indicates smells
    And it reports this JSON:
      """
      [
          {
              "smell_category": "IrresponsibleModule",
              "smell_type": "IrresponsibleModule",
              "source": "spec/samples/standard_smelly/minimal_dirty.rb",
              "context": "C",
              "lines": [
                  1
              ],
              "message": "has no descriptive comment",
              "name": "C"
          },
          {
              "smell_category": "UncommunicativeName",
              "smell_type": "UncommunicativeModuleName",
              "source": "spec/samples/standard_smelly/minimal_dirty.rb",
              "context": "C",
              "lines": [
                  1
              ],
              "message": "has the name 'C'",
              "name": "C"
          },
          {
              "smell_category": "UncommunicativeName",
              "smell_type": "UncommunicativeMethodName",
              "source": "spec/samples/standard_smelly/minimal_dirty.rb",
              "context": "C#m",
              "lines": [
                  2
              ],
              "message": "has the name 'm'",
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
              "smell_category": "IrresponsibleModule",
              "smell_type": "IrresponsibleModule",
              "source": "$stdin",
              "context": "Turn",
              "lines": [
                  1
              ],
              "message": "has no descriptive comment",
              "name": "Turn"
          }
      ]
      """
