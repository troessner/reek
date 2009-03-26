require 'reek/smells/smell_detector'
require 'reek/smell_warning'
require 'reek/sexp_formatter'

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
    class FeatureEnvy < SmellDetector

      def self.default_config
        super.adopt(EXCLUDE_KEY => ['initialize'])
      end

      def initialize(config = FeatureEnvy.default_config)
        super
      end

      #
      # Checks whether the given +context+ includes any code fragment that
      # might "belong" on another class.
      # Any smells found are added to the +report+.
      #
      def examine_context(context, report)
        context.envious_receivers.each do |ref|
          report << SmellWarning.new(self, context,
                      "refers to #{SexpFormatter.format(ref)} more than self")
        end
      end
    end
  end
end
