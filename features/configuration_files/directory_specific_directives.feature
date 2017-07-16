Feature: Directory directives
  In order to have a more fine-grained control over what Reek reports
  And to enable domain specific modes (like a Ruby on Rails mode)
  As a user
  I want to be able to configure Reek using directory directives

  Scenario: Configure multiple directories
    Given a file named "web_app/config.reek" with:
      """
      ---
      "web_app/app/controllers":
        IrresponsibleModule:
          enabled: false
        NestedIterators:
          enabled: false
      "web_app/app/helpers":
        IrresponsibleModule:
          enabled: false
        UtilityFunction:
          enabled: false
      """
    And a file named "web_app/app/controllers/users_controller.rb" with:
      """
      class UsersController < ApplicationController
        def show
          respond_with do |format|
            format.json { |json| @user.to_custom_json }
            format.xml { |xml| @user.to_fancy_xml }
          end
        end
      end
      """
    And a file named "web_app/app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def current_year
          Time.zone.now.year
        end
      end
      """
    And a file named "web_app/app/models/user.rb" with:
      """
      class User < ActiveRecord::Base
        def logged_in_with_role(role)
          true
        end
      end
      """
    When I run `reek -c web_app/config.reek web_app/`
    Then it reports:
    """
    web_app/app/controllers/users_controller.rb -- 1 warning:
      [1]:InstanceVariableAssumption: UsersController assumes too much for instance variable '@user' [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
    web_app/app/models/user.rb -- 2 warnings:
      [1]:IrresponsibleModule: User has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
      [2]:UnusedParameters: User#logged_in_with_role has unused parameter 'role' [https://github.com/troessner/reek/blob/master/docs/Unused-Parameters.md]
    3 total warnings
    """

  Scenario: Ignore trailing slashes
    Given a file named "web_app/config.reek" with:
      """
      ---
      "controllers/":
        IrresponsibleModule:
          enabled: false
      """
    And a file named "controllers/users_controller.rb" with:
      """
      class UsersController
        def show
        end
      end
      """
    When I run `reek -c web_app/config.reek controllers`
    Then it reports nothing

  Scenario: Partially mask smells in different directories
    Given a file named "web_app/config.reek" with:
      """
      ---
      "web_app/app/controllers":
        IrresponsibleModule:
          enabled: true
      "web_app/app/helpers":
        IrresponsibleModule:
          enabled: false
        UtilityFunction:
          enabled: false
      "web_app/app/models":
        IrresponsibleModule:
          enabled: false
      """
    And a file named "web_app/app/controllers/users_controller.rb" with:
      """
      class UsersController < ApplicationController
        def show
          respond_with do |format|
            format.json { |json| @user.to_custom_json }
          end
        end
      end
      """
    And a file named "web_app/app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def current_year
          Time.zone.now.year
        end
      end
      """
    And a file named "web_app/app/models/user.rb" with:
      """
      class User < ActiveRecord::Base
        def logged_in_with_role(role)
          true
        end
      end
      """
    When I run `reek -c web_app/config.reek web_app/`
    Then it reports:
    """
    web_app/app/controllers/users_controller.rb -- 3 warnings:
      [1]:InstanceVariableAssumption: UsersController assumes too much for instance variable '@user' [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
      [1]:IrresponsibleModule: UsersController has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
      [4]:NestedIterators: UsersController#show contains iterators nested 2 deep [https://github.com/troessner/reek/blob/master/docs/Nested-Iterators.md]
    web_app/app/models/user.rb -- 1 warning:
      [2]:UnusedParameters: User#logged_in_with_role has unused parameter 'role' [https://github.com/troessner/reek/blob/master/docs/Unused-Parameters.md]
    4 total warnings
    """

  Scenario: Use the default directive if there is no directory directive
    Given a file named "config.reek" with:
      """
      ---
      "web_app/app/controllers":
        IrresponsibleModule:
          enabled: true
        NestedIterators:
          enabled: false
      IrresponsibleModule:
        enabled: false
      NestedIterators:
        enabled: true
      """
    And a file named "web_app/app/controllers/users_controller.rb" with:
      """
      class UsersController < ApplicationController
        def show
          respond_with do |format|
            format.json { |json| @user.to_custom_json }
          end
        end
      end
      """
    And a file named "other/projects_controller.rb" with:
      """
      class ProjectController < ApplicationController
        def show
          respond_with do |format|
            format.json { |json| @project.to_custom_json }
          end
        end
      end
      """
    When I run `reek -c config.reek other/ web_app/`
    Then it reports:
    """
    other/projects_controller.rb -- 2 warnings:
      [1]:InstanceVariableAssumption: ProjectController assumes too much for instance variable '@project' [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
      [4]:NestedIterators: ProjectController#show contains iterators nested 2 deep [https://github.com/troessner/reek/blob/master/docs/Nested-Iterators.md]
    web_app/app/controllers/users_controller.rb -- 2 warnings:
      [1]:InstanceVariableAssumption: UsersController assumes too much for instance variable '@user' [https://github.com/troessner/reek/blob/master/docs/Instance-Variable-Assumption.md]
      [1]:IrresponsibleModule: UsersController has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
    4 total warnings
    """

  Scenario: Abort on non-existent smell type in directory directive
    Given a file named "config.reek" with:
      """
      ---
      "dummy_directory":
        # Typo: Should be NestedIterators
        IteratorsNested:
          enabled: false
      """
    And a file named "dummy_directory/dummy.rb" with:
      """
      class Dummy
      end
      """

    When I run `reek -c config.reek dummy_directory/`
    Then the exit status indicates an error
    And stderr reports:
    """
    You are trying to configure smell type IteratorsNested but we can't find one with that name.
    Please make sure you spelled it right. (See 'defaults.reek' in the Reek
    repository for a list of all available smell types.)

    """

  Scenario: Abort on file as directory directive
    Given a file named "config.reek" with:
      """
      ---
      "dummy_directory/dummy.rb":
        NestedIterators:
          enabled: false
      """
    And a file named "dummy_directory/dummy.rb" with:
      """
      class Dummy
      end
      """
    When I run `reek -c config.reek dummy_directory/`
    Then the exit status indicates an error
    And stderr reports:
    """
    Configuration error: `dummy_directory/dummy.rb` is supposed to be a directory but is a file

    """

  Scenario: In case of overlapping configurations, pick the most appropriate one
    Given a file named "config.reek" with:
      """
      ---
      "foo/bar/baz":
        IrresponsibleModule:
          enabled: false
        NestedIterators:
          enabled: true
      "foo/bar":
        IrresponsibleModule:
          enabled: true
        NestedIterators:
          enabled: false
      """
    And a file named "foo/bar/baz/klass.rb" with:
      """
      class Klass
        def meth
          respond_to do |arg|
            answer_to do |arg|
            end
          end
        end
      end
      """
    And a file named "foo/bar/klazz.rb" with:
      """
      class Klazz
        def meth
          respond_to do |arg|
            answer_to do |arg|
            end
          end
        end
      end
      """
    When I run `reek -c config.reek foo/`
    Then it reports:
    """
    foo/bar/baz/klass.rb -- 1 warning:
      [4]:NestedIterators: Klass#meth contains iterators nested 2 deep [https://github.com/troessner/reek/blob/master/docs/Nested-Iterators.md]
    foo/bar/klazz.rb -- 1 warning:
      [1]:IrresponsibleModule: Klazz has no descriptive comment [https://github.com/troessner/reek/blob/master/docs/Irresponsible-Module.md]
    2 total warnings
    """
