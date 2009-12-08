
module Reek

  #
  # A comment header from an abstract syntax tree; found directly above
  # module, class and method definitions.
  #
  class CodeComment

    def initialize(text)
      @text = text.gsub(/#/, '').gsub(/\n/, '').strip
    end
    def is_descriptive?
      @text.split(/\s+/).length >= 2
    end
  end
end
