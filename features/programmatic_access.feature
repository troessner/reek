Feature: Using reek programmatically
  In order to use reek from inside my program
  As a developer
  I want to be able to use its classes

  Scenario:
    Given a smelly file called 'smelly.rb'
    And a file named "examine.rb" with:
      """
      require 'reek'
      examiner = Reek::Core::Examiner.new(['smelly.rb'])
      examiner.smells.each do |smell|
        puts smell.message
      end
      """
    When I run `ruby examine.rb`
    Then it reports no errors
    And it reports:
      """
      calls @foo.bar 2 times
      calls puts(@foo.bar) 2 times
      has the name 'm'
      """

