require File.join( File.dirname( File.expand_path(__FILE__)), 'smell_detector')
require File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'smell_warning')

module Reek
  module Smells

    # 
    # A Utility Function is any instance method that has no
    # dependency on the state of the instance.
    # 
    # Currently +UtilityFunction+ will warn about any method that:
    # 
    # * is non-empty, and
    # * does not override an inherited method, and
    # * calls at least one method on another object, and
    # * doesn't use any of self's instance variables, and
    # * doesn't use any of self's methods
    #
    # A Utility Function often arises because it must manipulate
    # other objects (usually its arguments) to get them into a
    # useful form; one force preventing them (the
    # arguments) doing this themselves is that the common
    # knowledge lives outside the arguments, or the arguments
    # are of too basic a type to justify extending that type.
    # Therefore there must be something which 'knows' about the contents
    # or purposes of the arguments.  That thing would have to
    # be more than just a basic type, because the basic types
    # are either containers which don't know about their
    # contents, or they are single objects which can't capture
    # their relationship with their fellows of the same type.
    # So, this thing with the extra knowledge should be
    # reified into a class, and the utility method will most
    # likely belong there.
    #
    class UtilityFunction < SmellDetector

      # The name of the config field that sets the maximum number of
      # calls permitted within a helper method. Any method with more than
      # this number of method calls on other objects will be considered a
      # candidate Utility Function.
      HELPER_CALLS_LIMIT_KEY = 'max_helper_calls'

      DEFAULT_HELPER_CALLS_LIMIT = 1

      def self.default_config
        super.adopt(HELPER_CALLS_LIMIT_KEY => DEFAULT_HELPER_CALLS_LIMIT)
      end

      def initialize(source, config = UtilityFunction.default_config)
        super(source, config)
      end

      #
      # Checks whether the given +method+ is a utility function.
      # Remembers any smells found.
      #
      def examine_context(method_ctx)
        return false if method_ctx.num_statements == 0 or
          method_ctx.depends_on_instance? or
          num_helper_methods(method_ctx) <= value(HELPER_CALLS_LIMIT_KEY, method_ctx, DEFAULT_HELPER_CALLS_LIMIT)
          # SMELL: loads of calls to value{} with the above pattern
        smell = SmellWarning.new('LowCohesion', method_ctx.full_name, [method_ctx.exp.line],
          "doesn't depend on instance state", @masked,
          @source, 'UtilityFunction')
        @smells_found << smell
        #SMELL: serious duplication
      end

      def num_helper_methods(method_ctx)
        method_ctx.local_nodes(:call).length
      end
    end
  end
end
