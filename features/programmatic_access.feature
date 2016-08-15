Feature: Using Reek programmatically
  In order to use Reek from inside my program
  As a developer
  I want to be able to use its classes

  Scenario: Accessing smells found by an examiner
    Given the smelly file 'smelly.rb'
    And a file named "examine.rb" with:
      """
      require 'reek'
      examiner = Reek::Examiner.new(File.new('smelly.rb'))
      examiner.smells.each do |smell|
        puts smell.message
      end
      """
    When I run `ruby examine.rb`
    Then it reports no errors
    And it reports:
      """
      has the name 'x'
      has the variable name 'y'
      """

  Scenario: Using Reek's built-in report classes
    Given the smelly file 'smelly.rb'
    And a file named "examine.rb" with:
      """
      require 'reek'
      examiner = Reek::Examiner.new(File.new('smelly.rb'))
      report = Reek::Report::TextReport.new
      report.add_examiner examiner
      report.show
      """
    When I run `ruby examine.rb`
    Then it reports no errors
    And it reports:
      """
      smelly.rb -- 2 warnings:
        UncommunicativeMethodName: Smelly#x has the name 'x'
        UncommunicativeVariableName: Smelly#x has the variable name 'y'
      """
