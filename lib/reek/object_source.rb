module Reek
  def can_parse_objects?
    begin
      require 'parse_tree'
      true
    rescue LoadError
      false
    end
  end
  module_function :can_parse_objects?
end

if Reek.can_parse_objects?
  module Reek
    class Source
      #
      # Factory method: creates a +Source+ from obj.
      # The code is not parsed until +report+ is called.
      # (This feature is only enabled if you have the ParseTree gem installed.)
      #
      def self.from_object(obj)
        return ObjectSource.new(obj, obj.to_s)
      end
    end

    class ObjectSource < Source   # :nodoc:
      def check(parser) # :nodoc:
        parser.check_object(@source)
      end
    end
  end

  class Object
    #
    # Constructs a Source representing this object; the source can then be used
    # to generate an abstract syntax tree for the object, which can in turn then
    # be examined for code smells.
    # (This feature is only enabled if you have the ParseTree gem installed.)
    #
    def to_source
      Reek::Source.from_object(self)
    end
  end
else
  class Object
    def to_source
      throw ArgumentError.new('You must install the ParseTree gem to use this feature')
    end
  end
end
