require 'reek/examiner'

module Reek
  module Spec
    #
    # An rspec matcher that matches when the +actual+ has the specified
    # code smell.
    #
    class ShouldReekOf
      def initialize(smell_category, smell_details = {})
        @smell_category = normalize smell_category
        @smell_details  = smell_details
      end

      def matches?(actual)
        @examiner = Examiner.new(actual)
        @all_smells = @examiner.smells
        @all_smells.any? { |warning| warning.matches?(@smell_category, @smell_details) }
      end

      def failure_message
        "Expected #{@examiner.description} to reek of #{@smell_category}, but it didn't"
      end

      def failure_message_when_negated
        "Expected #{@examiner.description} not to reek of #{@smell_category}, but it did"
      end

      private

      def normalize(smell_category_or_type)
        # In theory, users can give us many different types of input (see the documentation for
        # reek_of below), however we're basically ignoring all of those subleties and just
        # return a string with the prepending namespace stripped.
        smell_category_or_type.to_s.split(/::/)[-1]
      end
    end

    #
    # Checks the target source code for instances of "smell category"
    # and returns true only if it can find one of them that matches.
    #
    # Remember that this includes our "smell types" as well. So it could be the
    # "smell type" UtilityFunction, which is represented as a concrete class
    # in reek but it could also be "Duplication" which is a "smell categgory".
    #
    # In theory you could pass many different types of input here:
    #   - :UtilityFunction
    #   - "UtilityFunction"
    #   - UtilityFunction (this works in our specs because we tend to do "include Reek:Smells")
    #   - Reek::Smells::UtilityFunction (the right way if you really want to pass a class)
    #   - "Duplication" or :Duplication which is an abstract "smell category"
    #
    # It is recommended to pass this as a symbol like :UtilityFunction. However we don't
    # enforce this.
    #
    # Additionally you can be more specific and pass in "smell_details" you
    # want to check for as well e.g. "name" or "count" (see the examples below).
    # The parameters you can check for are depending on the smell you are checking for.
    # For instance "count" doesn't make sense everywhere whereas "name" does in most cases.
    # If you pass in a parameter that doesn't exist (e.g. you make a typo like "namme") reek will
    # raise an ArgumentError to give you a hint that you passed something that doesn't make
    # much sense.
    #
    # smell_category - The "smell category" or "smell_type" we check for.
    # smells_details - A hash containing "smell warning" parameters
    #
    # Examples
    #
    #   Without smell_details:
    #
    #   reek_of(:FeatureEnvy)
    #   reek_of(Reek::Smells::UtilityFunction)
    #
    #   With smell_details:
    #
    #   reek_of(UncommunicativeParameterName, name: 'x2')
    #   reek_of(DataClump, count: 3)
    #
    # Examples from a real spec
    #
    #   expect(src).to reek_of(Reek::Smells::DuplicateMethodCall, name: '@other.thing')
    #
    def reek_of(smell_category, smell_details = {})
      ShouldReekOf.new(smell_category, smell_details)
    end
  end
end
