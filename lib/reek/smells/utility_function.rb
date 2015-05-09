require_relative 'smell_detector'
require_relative '../core/reference_collector'

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
    # If the method does refer to self, but refers to some other object more,
    # +FeatureEnvy+ is reported instead.
    #
    # See docs/Utility-Function for details.
    class UtilityFunction < SmellDetector
      def self.smell_category
        'LowCohesion'
      end

      class << self
        def contexts      # :nodoc:
          [:def]
        end
      end

      #
      # Checks whether the given +method+ is a utility function.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        return [] if method_ctx.num_statements == 0
        return [] if method_ctx.references_self?
        return [] if num_helper_methods(method_ctx).zero?

        [SmellWarning.new(self,
                          context: method_ctx.full_name,
                          lines: [method_ctx.exp.line],
                          message: "doesn't depend on instance state",
                          parameters: { name: method_ctx.full_name })]
      end

      private

      def num_helper_methods(method_ctx)
        method_ctx.local_nodes(:send).length
      end
    end
  end
end
