# frozen_string_literal: true
module Reek
  module Errors
    # Gets raised when trying to disable a smell that does not reek.
    # This might happen for multiple reasons. The users might have fixed
    # the smell or speculating in advance and forgetting to remove the.
    class UnneededSupression < RuntimeError
      UNNEEDED_SUPPRESSION_MESSAGE = <<-EOS.freeze
        Error: UnneededSuppression
      EOS

      def initialize
        message = format(UNNEEDED_SUPPRESSION_MESSAGE)
        super message
      end
    end
  end
end
