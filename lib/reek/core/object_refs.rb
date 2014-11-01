module Reek
  module Core
    #
    # Manages and counts the references out of a method to other objects.
    #
    class ObjectRefs  # :nodoc:
      def initialize
        @refs = Hash.new(0)
      end

      def record_reference_to(exp)
        @refs[exp] += 1
      end

      def references_to(exp)
        @refs[exp]
      end

      def max_refs
        @refs.values.max || 0
      end

      def max_keys
        max = max_refs
        @refs.select { |_key, val| val == max }
      end

      def self_is_max?
        max_keys.length == 0 || @refs[:self] == max_refs
      end
    end
  end
end
