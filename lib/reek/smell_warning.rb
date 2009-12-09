
module Reek

  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning

    include Comparable

    CONTEXT_KEY = 'context'

    def initialize(detector_class, context, lines, message, masked,
        source = '', subclass = '', parameters = [])
      @smell = {
        'class' => detector_class.class.name.split(/::/)[-1],
        'subclass' => subclass,
        'message' => message,
        'parameters' => parameters
      }
      @is_masked = masked
      @location = {
        CONTEXT_KEY => context,
        'lines' => lines,
        'source' => source
      }
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
      [@location[CONTEXT_KEY], @smell['message'], smell_name]
    end

    protected :sort_key

    def report(format)
      format.gsub(/\%s/, smell_name).
        gsub(/\%c/, @location[CONTEXT_KEY]).
        gsub(/\%w/, @smell['message']).
        gsub(/\%m/, @is_masked ? '(masked) ' : '')
    end

    def report_on(report)
      if @is_masked
        report.found_masked_smell(self)
      else
        report.found_smell(self)
      end
    end

    def smell_name
      @smell['class'].gsub(/([a-z])([A-Z])/) { |sub| "#{$1} #{$2}"}.split.join(' ')
    end
  end
end
