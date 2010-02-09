module Reek
  module Core

    #
    # Manages and counts the references out of a method to other objects.
    #
    class ObjectRefs  # :nodoc:
      def initialize
        @refs = Hash.new(0)
      end

      def record_reference_to_self
        record_ref(SELF_REF)
      end

      def record_ref(exp)
        type = exp[0]
        case type
        when :gvar
          return
        when :self
          record_reference_to_self
        else
          @refs[exp] += 1
        end
      end

      def refs_to_self
        @refs[SELF_REF]
      end

      def max_refs
        @refs.values.max or 0
      end

      def max_keys
        max = max_refs
        @refs.reject {|key,val| val != max}
      end

      def self_is_max?
        max_keys.length == 0 || @refs[SELF_REF] == max_refs
      end

    private

      SELF_REF = Sexp.from_array([:lit, :self])

    end
  end
end
