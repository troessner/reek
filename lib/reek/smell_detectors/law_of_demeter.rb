# frozen_string_literal: true

require_relative 'base_detector'

module Reek
  module SmellDetectors
    #
    # TODO:
    #
    # See {file:docs/Law-Of-Demeter.md} for details.
    class LawOfDemeter < BaseDetector
      Hit = Struct.new(:line, :name)

      ALLOWED_CALL_CHAIN_LENGTH = 1

      #
      # Checks the given +context+ for law of demeter violations.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        # How this currently works:
        # Given this code:
        #
        # def alfa(bravo)
        #   bravo.charlie.delta
        # end
        #
        # the corresponding tree of sexps looks like this:
        # s(:send,
        #   s(:send,
        #     s(:lvar, :bravo), :charlie), :delta)
        #
        # What we now do is:
        #
        # * Get all :send nodes
        # * Check for lvar nodes which correspond to one of our parameters. This gives us
        #   the `bravo.charlie` part from above
        # * Check if there are subsequent :send nodes. Since a `each_node(:send)` also includes
        #   the current :send node we have to remove this one from counting
        # * If there is another :send node present this means we violated Demeter's law
        parameter_names = expression.parameters.map(&:name)

        hits = []
        expression.each_node(:send) do |send_node|
          send_node.each_node(:lvar) do |lvar_node|
            next unless parameter_names.include?(lvar_node.name)
            if send_node.each_node(:send).reject {|other_send_node| other_send_node == send_node }.any?
              hits << Hit.new(lvar_node.line, lvar_node.name)
            end
          end
        end

        hits.map do |hit|
          smell_warning(
            lines: [hit.line],
            message: 'violates the law of demeter',
            parameters: { name: hit.name })
        end
      end
    end
  end
end
