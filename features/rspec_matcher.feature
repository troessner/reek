Feature: Use reek_of matcher
  As a developer
  In order to check code quality as part of my spec suite
  I want to assert that my code doesn't smell

  Background:
    Given the smelly file 'smelly.rb'
    And a file "reek_spec.rb" with:
    """
    require 'reek/spec'

    describe 'smelly.rb' do
      it 'is clean' do
        expect(Pathname.new('smelly.rb')).not_to reek
      end
    end
    """

  Scenario: Failing on a smelly file
    When I run `rspec reek_spec.rb`
    Then stdout should contain:
    """
    Failure/Error: expect(Pathname.new('smelly.rb')).not_to reek
    """

  Scenario: Masking smells with a configuration file
    Given a configuration file 'full_mask.reek'
    When I run `rspec reek_spec.rb`
    Then stdout should contain:
    """
    1 example, 0 failures
    """
