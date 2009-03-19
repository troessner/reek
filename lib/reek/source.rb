module Reek
  class Source
    attr_reader :filename
    
    def initialize(filename)
      @filename = filename
    end
  end
end
