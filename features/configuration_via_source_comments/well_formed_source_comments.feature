Feature: Well formed source comments are handled properly
  As a developer I want to be able to have a fine-grained control
  over how Reek handles smells via source code comments.

  Scenario: Disable smell detector implicitly
    Given a file named "disable_detector_implicitly.rb" with:
      """
      # Test class
      # :reek:TooManyInstanceVariables
      class Alfa
        def initialize
          @charlie = @delta = @echo = @foxtrot = @hotel = 1
        end
      end
      """
    When I run reek disable_detector_implicitly.rb
    Then it succeeds
    And it reports nothing

  Scenario: Disable smell detector explicitly
    Given a file named "disable_detector_explicitly.rb" with:
      """
      # Test class
      # :reek:TooManyInstanceVariables { enabled: false }
      class Alfa
        def initialize
          @charlie = @delta = @echo = @foxtrot = @hotel = 1
        end
      end
      """
    When I run reek disable_detector_explicitly.rb
    Then it succeeds
    And it reports nothing

  Scenario: Enable smell detector explicitly
    Given a file named "enable_detector_explicitly.rb" with:
      """
      # Test class
      # :reek:TooManyInstanceVariables { enabled: true }
      class Alfa
        def initialize
          @charlie = @delta = @echo = @foxtrot = @hotel = 1
        end
      end
      """
    When I run reek enable_detector_explicitly.rb
    Then the exit status indicates smells
    And it reports:
      """
      enable_detector_explicitly.rb -- 1 warning:
        [3]:TooManyInstanceVariables: Alfa has at least 5 instance variables [https://github.com/troessner/reek/blob/master/docs/Too-Many-Instance-Variables.md]
      """

  Scenario: Configure smell detector with the basic exclude option as string
    Given a file named "configure_exclude_option.rb" with:
      """
      # Test class
      # :reek:TooManyInstanceVariables { exclude: '@hotel' }
      class Alfa
        def initialize
          @charlie = @delta = @echo = @foxtrot = @hotel = 1
        end
      end
      """
    When I run reek configure_exclude_option.rb
    Then it succeeds
    And it reports nothing

  Scenario: Configure smell detector with the basic exclude option as regex
    Given a file named "configure_exclude_option.rb" with:
      """
      # Test class
      # :reek:TooManyInstanceVariables { exclude: /hotel/ }
      class Alfa
        def initialize
          @charlie = @delta = @echo = @foxtrot = @hotel = 1
        end
      end
      """
    When I run reek configure_exclude_option.rb
    Then it succeeds
    And it reports nothing

  Scenario: Configure smell detector with a detector specific option that silences it
    Given a file named "configure_detector_specific_option.rb" with:
    """
      # Test class
      # :reek:TooManyInstanceVariables { max_instance_variables: 5 }
      class Alfa
        def initialize
          @charlie = @delta = @echo = @foxtrot = @hotel = 1
        end
      end
      """
    When I run reek configure_detector_specific_option.rb
    Then it succeeds
    And it reports nothing

  Scenario: Configure smell detector with a detector specific option that makes it report again
    Given a file named "configure_detector_specific_option.rb" with:
    """
      # Test class
      # :reek:TooManyInstanceVariables { max_instance_variables: 2 }
      class Alfa
        def initialize
          @charlie = @delta = @echo = 1
        end
      end
      """
    When I run reek configure_detector_specific_option.rb
    Then the exit status indicates smells
    And it reports:
      """
      configure_detector_specific_option.rb -- 1 warning:
        [3]:TooManyInstanceVariables: Alfa has at least 3 instance variables [https://github.com/troessner/reek/blob/master/docs/Too-Many-Instance-Variables.md]
      """
