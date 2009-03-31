require 'reek/code_parser'
require 'reek/report'
require 'reek/smells/smells'

module Reek

  #
  # A +Source+ object represents a chunk of Ruby source code.
  #
  # The various class methods are factories that will create +Source+
  # instances from various types of input.
  #
  class Source

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # the +IO+ stream. The stream is consumed upto end-of-file, but the
    # source code is not parsed until +report+ is called. +desc+ provides
    # a string description to be used in the header of formatted reports.
    #
    def self.from_io(ios, desc)
      code = ios.readlines.join
      return new(code, desc)
    end

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # the +code+ string. The code is not parsed until +report+ is called.
    #
    def self.from_s(code)
      return new(code, 'string')
    end

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # File +file+. The source code is not parsed until +report+ is called.
    #
    def self.from_f(file)
      from_path(file.path)
    end

    #
    # Factory method: creates a +Source+ object by reading Ruby code from
    # the named file. The source code is not parsed until +report+ is called.
    #
    def self.from_path(filename)
      code = IO.readlines(filename).join
      return new(code, filename, File.dirname(filename))
    end

    #
    # Factory method: creates a +Source+ object from an array of file paths.
    # No source code is actually parsed until the report is accessed.
    #
    def self.from_pathlist(paths)
      sources = paths.map {|path| Source.from_path(path) }
      SourceList.new(sources)
    end

    def initialize(code, desc, dir = '.')     # :nodoc:
      @source = code
      @dir = dir
      @desc = desc
    end

    #
    # Returns a +Report+ listing the smells found in this source. The first
    # call to +report+ parses the source code and constructs a list of
    # +SmellWarning+s found; subsequent calls simply return this same list.
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

    #
    # Checks this source for instances of +smell_class+, and returns +true+
    # only if one of them has a report string matching all of the +patterns+.
    #
    def has_smell?(smell_class, patterns)
      report.any? { |smell| smell.matches?(smell_class, patterns) }
    end

    def to_s
      @desc
    end
  end

  #
  # Represents a list of Sources as if they were a single source.
  #
  class SourceList
    def initialize(sources)
      @sources = sources
    end

    def smelly?
      @sources.any? {|source| source.smelly? }
    end

    def report
      @sources.select {|src| src.smelly? }.map do |src|
        warnings = src.report
        "\"#{src}\" -- #{warnings.length} warnings:\n#{warnings.to_s}\n"
      end.join("\n")
    end
  end
end
