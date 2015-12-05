require 'private_attr/everywhere'

module Reek
  module Context
    # Responsible for tracking visibilities in regards to CodeContexts.
    # :reek:Attribute
    class VisibilityTracker
      attr_accessor :visibility
      private_attr_accessor :tracked_visibility

      def initialize(visibility = :public)
        @visibility = visibility
      end

      # Handle the effects of a visibility modifier.
      #
      # @example Modifying the visibility of existing children
      #   track_visibility children, :private, [:hide_me, :implementation_detail]
      #
      # @param children [Array<CodeContext>]
      # @param visibility [Symbol]
      # @param names [Array<Symbol>]
      #
      def track_visibility(children: raise, visibility: raise, names: raise)
        if names.any?
          children.each do |child|
            child.visibility = visibility if names.include?(child.name)
          end
        else
          self.tracked_visibility = visibility
        end
      end

      # Sets the visibility of a child CodeContext to the tracked visibility.
      #
      # @param child [CodeContext]
      #
      def set_child_visibility(child)
        child.visibility = tracked_visibility
      end

      # return [Boolean] If the visibility is public or not.
      def non_public_visibility?
        visibility != :public
      end

      private

      def tracked_visibility
        @tracked_visibility ||= :public
      end
    end
  end
end
