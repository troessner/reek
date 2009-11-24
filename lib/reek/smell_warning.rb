module Reek

  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable

    def initialize(detector_class, context, warning, masked)
      @detector_name = detector_class.class.name
      @context = context
      @warning = warning
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
      [@context.to_s, @warning, smell_name]
    end

    protected :sort_key

    def report(format)
      format.gsub(/\%s/, smell_name).gsub(/\%c/, @context.to_s).gsub(/\%w/, @warning).gsub(/\%m/, @is_masked ? '(masked) ' : '')
    end

    def report_on(report)
      if @is_masked
        report.found_masked_smell(self)
      else
        report.found_smell(self)
      end
    end

    def smell_name
      class_name = @detector_name.split(/::/)[-1]
      class_name.gsub(/([a-z])([A-Z])/) { |sub| "#{$1} #{$2}"}.split.join(' ')
    end
  end
end
