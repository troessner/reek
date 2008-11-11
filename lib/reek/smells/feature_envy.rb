$:.unshift File.dirname(__FILE__)

require 'reek/smells/smell'

module Reek
  module Smells

    class FeatureEnvy < Smell

      def recognise?(refs)
        @refs = refs
        !refs.self_is_max?
      end

      def detailed_report
        receiver = @refs.max_keys.map {|r| Printer.print(r)}.sort.join(' and ')
        "#{@context} uses #{receiver} more than self"
      end
    end

  end
end
