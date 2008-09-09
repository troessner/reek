$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'

module Reek

  class Checker < SexpProcessor
    attr_accessor :description

    # Creates a new Ruby code checker. Any smells discovered by
    # +check_source+ or +check_object+ will be stored in +report+.
    def initialize(report)
      super()
      @require_empty = false
      @smells = report
      @description = ''
      @unsupported -= [:cfunc]
    end

    def report(smell)  # :nodoc:
      @smells << smell
    end

    # Analyses the given Ruby source +code+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_source(code)
      check_parse_tree ParseTree.new.parse_tree_for_string(code)
    end

    # Analyses the given Ruby object +obj+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_object(obj)
      check_parse_tree ParseTree.new.parse_tree(obj)
    end
    
    def to_s  # :nodoc:
      description
    end

    def check_parse_tree(sexp)  # :nodoc:
      sexp.each { |exp| process(exp) }
    end
  end
end
