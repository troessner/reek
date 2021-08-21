# frozen_string_literal: true

require 'forwardable'
require_relative 'documentation_link'

module Reek
  #
  # Reports a warning that a smell has been found.
  #
  # @public
  #
  # @quality :reek:TooManyInstanceVariables { max_instance_variables: 6 }
  class SmellWarning
    include Comparable
    extend Forwardable

    # @public
    attr_reader :context, :lines, :message, :parameters, :smell_type, :source

    # @param smell_type [String] type of detected smell; corresponds to
    #   detector#smell_type
    # @param context [String] name of the context in which the smell occured
    # @param lines [Array<Integer>] list of lines on which the smell occured
    # @param message [String] text describing the smell in more detail
    # @param source [String] name of the source (e.g., the file name) in which
    #   the smell occured
    # @param parameters [Hash] smell-specific parameters
    #
    # @note When using Reek's public API, you should not create SmellWarning
    #   objects yourself. This is why the initializer is not part of the
    #   public API.
    #
    # @quality :reek:LongParameterList { max_params: 6 }
    def initialize(smell_type, lines:, message:, source:, context: '', parameters: {})
      @smell_type = smell_type
      @source     = source
      @context    = context.to_s
      @lines      = lines
      @message    = message
      @parameters = parameters

      freeze
    end

    # @public
    def hash
      identifying_values.hash
    end

    # @public
    def <=>(other)
      identifying_values <=> other.identifying_values
    end

    # @public
    def eql?(other)
      (self <=> other).zero?
    end

    # @public
    def to_hash
      stringified_params = parameters.transform_keys(&:to_s)
      base_hash.merge(stringified_params)
    end

    def yaml_hash
      to_hash.merge('documentation_link' => explanatory_link)
    end

    def base_message
      "#{smell_type}: #{context} #{message}"
    end

    def explanatory_link
      DocumentationLink.build(smell_type)
    end

    protected

    def identifying_values
      [smell_type, context, message, lines]
    end

    private

    def base_hash
      {
        'context'    => context,
        'lines'      => lines,
        'message'    => message,
        'smell_type' => smell_type,
        'source'     => source
      }
    end
  end
end
