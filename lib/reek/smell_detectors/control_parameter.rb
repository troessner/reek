# frozen_string_literal: true

require_relative 'base_detector'
require_relative 'control_parameter_helpers/candidate'
require_relative 'control_parameter_helpers/control_parameter_finder'

module Reek
  module SmellDetectors
    #
    # Control Coupling occurs when a method or block checks the value of
    # a parameter in order to decide which execution path to take. The
    # offending parameter is often called a Control Couple.
    #
    # A simple example would be the <tt>quoted</tt> parameter
    # in the following method:
    #
    #  def write(quoted)
    #    if quoted
    #      write_quoted(@value)
    #    else
    #      puts @value
    #    end
    #  end
    #
    # Control Coupling is a kind of duplication, because the calling method
    # already knows which path should be taken.
    #
    # Control Coupling reduces the code's flexibility by creating a
    # dependency between the caller and callee:
    # any change to the possible values of the controlling parameter must
    # be reflected on both sides of the call.
    #
    # A Control Couple also reveals a loss of simplicity: the called
    # method probably has more than one responsibility,
    # because it includes at least two different code paths.
    #
    # One possible solution is to use the Strategy Pattern
    # to pass into the callee what must be done.  This is
    # not considered to be control coupling because the
    # callee will do the same thing with the strategy,
    # whatever it happens to be.  Sometimes in Ruby the
    # strategy may actually just be a block passed in, and
    # that remains next to where the caller invokes it in
    # the source code.
    #
    # See {file:docs/Control-Parameter.md} for details.
    class ControlParameter < BaseDetector
      #
      # Checks whether the given method chooses its execution path
      # by testing the value of one of its parameters.
      #
      # @return [Array<SmellWarning>]
      #
      def sniff
        control_parameters.map do |control_parameter|
          argument = control_parameter.name.to_s
          smell_warning(
            lines: control_parameter.lines,
            message: "is controlled by argument '#{argument}'",
            parameters: { argument: argument })
        end
      end

      private

      #
      # @return [Array<ControlParameterHelpers::Candidate>]
      #
      def control_parameters
        potential_parameters.
          map { |parameter| ControlParameterHelpers::Candidate.new(parameter, find_matches(parameter)) }.
          select(&:smells?)
      end

      #
      # @return [Array<Symbol>] e.g. [:bravo, :charlie]
      #
      def potential_parameters
        expression.parameter_names
      end

      #
      # @param parameter [Symbol] the name of the parameter
      # @return [Array<Reek::AST::Node>]
      #
      def find_matches(parameter)
        ControlParameterHelpers::ControlParameterFinder.new(expression, parameter).find_matches
      end
    end
  end
end
