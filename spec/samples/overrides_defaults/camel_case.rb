# Class containing camelCase variable which would normally smell
class CamelCase
  def initialize
    # These next two would normally smell if it weren't for overridden config values
    camelCaseVariable = []
    anotherOne = 1

    # this next one should still smell
    x1 = 0

    # this next one should not smell
    should_not_smell = true
  end
end
