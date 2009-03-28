require 'reek/code_parser'

module Reek
  class Source
    def self.from_io(ios, desc)
      code = ios.readlines.join
      return new(code, desc)
    end

    def self.from_s(code)
      return new(code, 'string')
    end

    def self.from_f(file)
      from_path(file.path)
    end

    def self.from_path(filename)
      code = IO.readlines(filename).join
      return new(code, filename, File.dirname(filename))
    end

    def initialize(code, desc, dir = '.')
      @source = code
      @dir = dir
      @desc = desc
    end

    #
    # Returns a +Report+ listing the smells found in this source.
    #
    def report
      unless @report
        @report = Report.new
        smells = SmellConfig.new.load_local(@dir).smell_listeners
        CodeParser.new(@report, smells).check_source(@source)
      end
      @report
    end

    def smelly?
      report.length > 0
    end

    def has_smell?(smell_sym, patterns)
      report.any? { |smell| smell.matches?(smell_sym, patterns) }
    end

    def to_s
      @desc
    end
  end
end
