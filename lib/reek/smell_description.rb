module Reek
  class SmellDescription
    attr_reader :smell_class, :smell_subclass, :message, :details

    def initialize(smell_class, smell_subclass, message, details)
      @smell_class = smell_class
      @smell_subclass = smell_subclass
      @message = message
      @details = details
    end

    def [](key)
      @details[key]
    end

    def encode_with coder
      coder.tag = nil
      coder['class'] = @smell_class
      coder['subclass'] = @smell_subclass
      coder['message'] = @message
      @details.each do |k, v|
        coder[k] = v
      end
    end
  end
end
