module Reek

  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable

    def initialize(smell, context, warning, masked)
      @detector = smell
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

    #
    # Returns +true+ only if this is a warning about an instance of
    # +smell_class+ and its report string matches all of the +patterns+.
    #
    def matches?(smell_class, patterns)
      return false unless smell_class.to_s == @detector.class.class_name
      contains_all?(patterns)
    end

    def contains_all?(patterns)
      rpt = sort_key.to_s
      return patterns.all? {|exp| exp === rpt}
    end

    def sort_key
      [@context.to_s, @warning, @detector.smell_name]
    end

    protected :sort_key

    def report(format)
      format.gsub(/\%s/, @detector.smell_name).gsub(/\%c/, @context.to_s).gsub(/\%w/, @warning).gsub(/\%m/, @is_masked ? '(masked) ' : '')
    end

    def report_on(report)
      if @is_masked
        report.found_masked_smell(self)
      else
        report.found_smell(self)
      end
    end
  end
end
