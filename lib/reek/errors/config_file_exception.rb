# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Raised when config file is not properly readable.
    class ConfigFileException < BaseError
    end
  end
end
