require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # Feature Envy occurs when a code fragment references another object
    # more often than it references itself, or when several clients do
    # the same series of manipulations on a particular type of object.
    #
    # A simple example would be the following method, which "belongs"
    # on the Item class and not on the Cart class:
    #
    #  class Cart
    #    def price
    #      @item.price + @item.tax
    #    end
    #  end
    #
    # Feature Envy reduces the code's ability to communicate intent:
    # code that "belongs" on one class but which is located in another
    # can be hard to find, and may upset the "System of Names"
    # in the host class.
    #
    # Feature Envy also affects the design's flexibility: A code fragment
    # that is in the wrong class creates couplings that may not be natural
    # within the application's domain, and creates a loss of cohesion
    # in the unwilling host class.
    #
    # Currently +FeatureEnvy+ reports any method that refers to self less
    # often than it refers to (ie. send messages to) some other object.
    #
    # If the method doesn't reference self at all, +UtilityFunction+ is
    # reported instead.
    #
    # See {file:docs/Feature-Envy.md} for details.
    # @api private
    class FeatureEnvy < SmellDetector
      def self.smell_category
        'LowCohesion'
      end

      #
      # Checks whether the given +context+ includes any code fragment that
      # might "belong" on another class.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(method_ctx)
        return [] unless method_ctx.references_self?
        method_ctx.envious_receivers.map do |name, refs|
          SmellWarning.new self,
                           context: method_ctx.full_name,
                           lines: refs.map(&:line),
                           message: "refers to #{name} more than self",
                           parameters: { name: name.to_s, count: refs.size }
        end
      end
    end
  end
end
