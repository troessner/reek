require 'forwardable'

module Reek
  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable
    extend Forwardable
    attr_accessor :smell_detector, :context, :lines, :message, :parameters
    def_delegators :smell_detector, :smell_category, :smell_type, :source

    def initialize(smell_detector, options = {})
      self.smell_detector = smell_detector
      self.context        = options.fetch(:context, '').to_s
      self.lines          = options.fetch(:lines)
      self.message        = options.fetch(:message)
      self.parameters     = options.fetch(:parameters, {})
    end

    def smell_classes
      [smell_detector.smell_category, smell_detector.smell_type]
    end

    def hash
      sort_key.hash
    end

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def eql?(other)
      (self <=> other) == 0
    end

    def matches?(klass, other_parameters = {})
      smell_classes.include?(klass.to_s) && common_parameters_equal?(other_parameters)
    end

    def report_on(listener)
      listener.found_smell(self)
    end

    def yaml_hash
      result = {
        'smell_category' => smell_detector.smell_category,
        'smell_type'     => smell_detector.smell_type,
        'source'         => smell_detector.source,
        'context'        => context,
        'lines'          => lines,
        'message'        => message
      }
      parameters.each do |key, value|
        result[key.to_s] = value
      end
      result
    end

    protected

    def sort_key
      [context, message, smell_category]
    end

    def common_parameters_equal?(other_parameters)
      other_parameters.keys.each do |key|
        unless parameters.key?(key)
          raise ArgumentError, "The parameter #{key} you want to check for doesn't exist"
        end
      end

      # Why not check for strict parameter equality instead of just the common ones?
      #
      # In `self`, `parameters` might look like this:  {:name=>"@other.thing", :count=>2}
      # Coming from specs, 'other_parameters' might look like this, e.g.:
      # {:name=>"@other.thing"}
      # So in this spec we are just specifying the "name" parameter but not the "count".
      # In order to allow for this kind of leniency we just test for common parameter equality,
      # not for a strict one.
      parameters.values_at(*other_parameters.keys) == other_parameters.values
    end
  end
end
