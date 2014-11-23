require 'reek/smell_description'

module Reek
  #
  # Reports a warning that a smell has been found.
  #
  class SmellWarning
    include Comparable

    def initialize(class_name, context, lines, message,
        source = '', subclass_name = '', parameters = {})
      @smell = SmellDescription.new(class_name, subclass_name, message, parameters)
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

    def smell_classes() [smell_class, subclass] end
    def smell_class() @smell.smell_class end
    def subclass() @smell.smell_subclass end
    def message() @smell.message end

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

    def init_with(coder)
      @location = coder['location']
      smell_attributes = coder['smell']
      smell_class = smell_attributes.delete('class')
      smell_subclass = smell_attributes.delete('subclass')
      smell_message = smell_attributes.delete('message')
      @smell = SmellDescription.new(smell_class,
                                    smell_subclass,
                                    smell_message,
                                    smell_attributes)
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
