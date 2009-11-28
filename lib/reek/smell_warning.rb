module Reek

  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable

    def initialize(detector_class, context, line, message, masked)
      @smell = detector_class.class.name.split(/::/)[-1]
      @context = context
      @line = line
      @message = message
      @is_masked = masked
    end

    def hash  # :nodoc:
      sort_key.hash
    end

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def eql?(other)
      (self <=> other) == 0
    end

    def contains_all?(patterns)
      rpt = sort_key.to_s
      return patterns.all? {|exp| exp === rpt}
    end

    def sort_key
      [@context, @message, smell_name]
    end

    protected :sort_key

    def report(format)
      format.gsub(/\%s/, smell_name).gsub(/\%c/, @context).gsub(/\%w/, @message).gsub(/\%m/, @is_masked ? '(masked) ' : '')
    end

    def report_on(report)
      if @is_masked
        report.found_masked_smell(self)
      else
        report.found_smell(self)
      end
    end

    def smell_name
      @smell.gsub(/([a-z])([A-Z])/) { |sub| "#{$1} #{$2}"}.split.join(' ')
    end
  end
end
