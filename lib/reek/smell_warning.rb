require 'reek/options'

module Reek

  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable

    def initialize(smell, context, warning)
      @smell = smell
      @context = context
      @warning = warning
    end

    def hash  # :nodoc:
      report.hash
    end

    def <=>(other)
      report <=> other.report
    end

    alias eql? <=>  # :nodoc:

    def matches?(name_sym, patterns)
      name_sym.to_s == @smell.class.class_name
    end

    #
    # Returns a copy of the current report format (see +Options+)
    # in which the following magic tokens have been substituted:
    #
    # * %s <-- the name of the smell that was detected
    # * %c <-- a description of the +CodeContext+ containing the smell
    # * %w <-- the specific problem that was detected
    #
    def report
      Options[:format].gsub(/\%s/, @smell.smell_name).gsub(/\%c/, @context.to_s).gsub(/\%w/, @warning)
    end
  end
end
