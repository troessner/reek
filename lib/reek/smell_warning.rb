require 'reek/smell_description'
require 'forwardable'

module Reek
  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable
    extend Forwardable
    attr_accessor :smell_detector, :context, :lines, :parameters
    def_delegators :smell_detector, :smell_class, :smell_sub_class, :source

    def initialize(smell_detector, options = {})
      self.smell_detector = smell_detector
      self.context        = options.fetch(:context, '').to_s
      self.lines          = options.fetch(:lines, [])
      self.parameters     = options.fetch(:parameters, {})
    end

    def message
      smell_detector.message_template % parameters.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
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
      smell_detector.smell_classes.include?(klass.to_s) && contains_all?(patterns)
    end

    def report_on(listener)
      listener.found_smell(self)
    end

    protected

    def contains_all?(patterns)
      rpt = sort_key.to_s
      patterns.all? { |pattern| pattern =~ rpt }
    end

    def sort_key
      [context, message, smell_class]
    end
  end
end
