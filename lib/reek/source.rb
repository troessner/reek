module Reek
  class Source
    attr_reader :source

    def initialize(filename)
      if File.exists?(filename)
        @source = IO.readlines(filename).join
        @dir = File.dirname(filename)
      else
        @source = filename
        @dir = '.'
      end
    end

    def configure(config)
      config.load_local(@dir)
    end
  end
end
