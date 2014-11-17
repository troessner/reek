module Reek
  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable

    def initialize(class_name, context, lines, message,
        source = '', subclass_name = '', parameters = {})
      @smell = {
        'class'    => class_name,
        'subclass' => subclass_name,
        'message'  => message
      }
      @smell.merge!(parameters)
      @location = {
        'context' => context.to_s,
        'lines'   => lines,
        'source'  => source
      }
    end

    #
    # Details of the smell found, including its class, subclass and summary message.
    #
    # @return [Hash{String => String}]
    #
    attr_reader :smell

    def smell_class() @smell.fetch('class') end
    def subclass() @smell.fetch('subclass') end
    def message() @smell.fetch('message') end
    def smell_classes() [smell_class, subclass] end

    #
    # Details of the smell's location, including its context,
    # the line numbers on which it occurs and the source file
    #
    # @return [Hash{String => String, Array<Number>}]
    #
    attr_reader :location

    def context() @location.fetch('context') end
    def lines() @location.fetch('lines') end
    def source() @location.fetch('source') end

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
