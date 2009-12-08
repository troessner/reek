
module Reek
  class CodeComment

    def initialize(text)
      @text = text.gsub(/#/, '').gsub(/\n/, '').strip
    end
    def is_descriptive?
      @text.split(/\s+/).length >= 2
    end
  end
end
