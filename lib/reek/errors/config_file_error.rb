# frozen_string_literal: true

require_relative 'base_error'

module Reek
  module Errors
    # Gets raised when Reek is unable to process the source due to bad config file
    class ConfigFileException < BaseError
    end
  end
end
