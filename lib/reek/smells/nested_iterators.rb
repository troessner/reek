$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    class NestedIterators < Smell
      def recognise?(already_in_iter)
        already_in_iter && @context
      end

      def detailed_report
        "#{@context} has nested iterators"
      end
    end

  end
end
