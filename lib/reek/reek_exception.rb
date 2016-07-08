# frozen_string_literal: true
module Reek
  #
  # @public
  #
  # ReekException is the only exception that Reek should give back
  # to the user in case something goes wrong.
  class ReekException < RuntimeError
  end
end
