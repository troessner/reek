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

    def matches?(klass, patterns)
      smell_classes.include?(klass.to_s) && contains_all?(patterns)
    end

    def report_on(listener)
      listener.found_smell(self)
    end

    def encode_with(coder)
      coder.tag = nil
      coder['smell_category']  = smell_detector.smell_category
      coder['smell_type']      = smell_detector.smell_type
      coder['source']          = smell_detector.source
      coder['context']         = context
      coder['lines']           = lines
      coder['message']         = message
      parameters.each do |key, value|
        coder[key.to_s] = value
      end
    end

    protected

    def contains_all?(patterns)
      rpt = sort_key.to_s
      patterns.all? { |pattern| pattern =~ rpt }
    end

    def sort_key
      [context, message, smell_category]
    end
  end
end
