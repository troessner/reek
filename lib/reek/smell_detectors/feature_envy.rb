# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
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
    class FeatureEnvy < BaseDetector
      #
      # Checks whether the given +context+ includes any code fragment that
      # might "belong" on another class.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff(ctx)
        return [] unless ctx.references_self?
        envious_receivers(ctx).map do |name, lines|
          smell_warning(
            context: ctx,
            lines: lines,
            message: "refers to '#{name}' more than self (maybe move it to another class?)",
            parameters: { name: name.to_s })
        end
      end

      private

      # :reek:UtilityFunction
      def envious_receivers(ctx)
        refs = ctx.refs
        return {} if refs.self_is_max?
        refs.most_popular
      end
    end
  end
end
