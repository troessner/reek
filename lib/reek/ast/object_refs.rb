module Reek
  # @api private
  module AST
    ObjectRef = Struct.new(:name, :line)
    #
    # Manages and counts the references out of a method to other objects.
    #
    class ObjectRefs
      def initialize
        @refs = Hash.new { |refs, name| refs[name] = [] }
      end

      def most_popular
        max = refs.values.map(&:size).max
        refs.select { |_name, refs| refs.size == max }
      end

      def record_reference_to(name, line: nil)
        refs[name] << ObjectRef.new(name, line)
      end

      def references_to(name)
        refs[name]
      end

      def self_is_max?
        refs.empty? || most_popular.keys.include?(:self)
      end

      private

      private_attr_reader :refs
    end
  end
end
