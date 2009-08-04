require 'reek/command_line'    # SMELL: Global Variable used for options

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
      basic_report.hash
    end

    def <=>(other)
      basic_report <=> other.basic_report
    end

    alias eql? <=>  # :nodoc:

    #
    # Returns +true+ only if this is a warning about an instance of
    # +smell_class+ and its report string matches all of the +patterns+.
    #
    def matches?(smell_class, patterns)
      return false unless smell_class.to_s == @detector.class.class_name
      contains_all?(patterns)
    end

    def contains_all?(patterns)
      rpt = report
      return patterns.all? {|exp| exp === rpt}
    end

    def basic_report
      Options[:format].gsub(/\%s/, @detector.smell_name).gsub(/\%c/, @context.to_s).gsub(/\%w/, @warning)
    end

    #
    # Returns a copy of the current report format (see +Options+)
    # in which the following magic tokens have been substituted:
    #
    # * %c <-- a description of the +CodeContext+ containing the smell
    # * %m <-- "(is_masked) " if this is a is_masked smell
    # * %s <-- the name of the smell that was detected
    # * %w <-- the specific problem that was detected
    #
    def report
      basic_report.gsub(/\%m/, @is_masked ? '(masked) ' : '')
    end

    def report_on(report)
      if @is_masked
        report.record_masked_smell(self)
      else
        report << self
      end
    end
  end
end
