$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'

module Reek

  class Checker < SexpProcessor

    def self.parse_tree_for(code)   # :nodoc:
      ParseTree.new.parse_tree_for_string(code)
    end

    # Creates a new Ruby code checker. Any smells discovered by
    # +check_source+ or +check_object+ will be stored in +report+.
    def initialize(report)
      super()
      @smells = report
      @unsupported -= [:cfunc]
      @default_method = :process_default
      @require_empty = @warn_on_default = false
    end

    def process_default(exp)
      exp[1..-1].each { |sub| process(sub) if Array === sub}
      s(exp)
    end

    # Analyses the given Ruby source +code+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_source(code)
      check_parse_tree(Checker.parse_tree_for(code))
    end

    # Analyses the given Ruby object +obj+ looking for smells.
    # Any smells found are saved in the +Report+ object that
    # was passed to this object's constructor.
    def check_object(obj)
      check_parse_tree ParseTree.new.parse_tree(obj)
    end

    def check_parse_tree(sexp)  # :nodoc:
      sexp.each { |exp| process(exp) }
    end
  end
end

# SMELL:
# This is here to resolve a circular dependency -- MethodChecker inherits
# Checker, which calls MethodChecker. Yuk!
require 'reek/method_checker'
