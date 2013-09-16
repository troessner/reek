module Reek

  #
  # Reports a warning that a smell has been found.
  # This object is essentially a DTO, and therefore contains a :reek:attribute or two.
  #
  class SmellWarning

    include Comparable

    MESSAGE_KEY = 'message'
    SUBCLASS_KEY = 'subclass'
    CLASS_KEY = 'class'

    CONTEXT_KEY = 'context'
    LINES_KEY = 'lines'
    SOURCE_KEY = 'source'

    ACTIVE_KEY = 'is_active'

    def initialize(class_name, context, lines, message,
        source = '', subclass_name = '', parameters = {})
      @smell = {
        CLASS_KEY => class_name,
        SUBCLASS_KEY => subclass_name,
        MESSAGE_KEY => message,
      }
      @smell.merge!(parameters)
      @status = {
        ACTIVE_KEY => true
      }
      @location = {
        CONTEXT_KEY => context.to_s,
        LINES_KEY => lines,
        SOURCE_KEY => source
      }
    end

    #
    # Details of the smell found, including its class ({CLASS_KEY}),
    # subclass ({SUBCLASS_KEY}) and summary message ({MESSAGE_KEY})
    #
    # @return [Hash{String => String}]
    #
    attr_reader :smell

    def smell_class() @smell[CLASS_KEY] end
    def subclass() @smell[SUBCLASS_KEY] end
    def message() @smell[MESSAGE_KEY] end

    #
    # Details of the smell's location, including its context ({CONTEXT_KEY}),
    # the line numbers on which it occurs ({LINES_KEY}) and the source
    # file ({SOURCE_KEY})
    #
    # @return [Hash{String => String, Array<Number>}]
    #
    attr_reader :location

    def context() @location[CONTEXT_KEY] end
    def lines() @location[LINES_KEY] end
    def source() @location[SOURCE_KEY] end

    #
    # Details of the smell's status, including whether it is active ({ACTIVE_KEY})
    # (as opposed to being masked by a config file)
    #
    # @return [Hash{String => Boolean}]
    #
    attr_reader :status

    def is_active() @status[ACTIVE_KEY] end

    def hash
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
      return patterns.all? {|pattern| pattern === rpt}
    end

    def matches?(klass, patterns)
      @smell.values.include?(klass.to_s) and contains_all?(patterns)
    end

    def report_on(listener)
      listener.found_smell(self)
    end

  protected

    def sort_key
      [@location[CONTEXT_KEY], @smell[MESSAGE_KEY], @smell[CLASS_KEY]]
    end
  end
end
