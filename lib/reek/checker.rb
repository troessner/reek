$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'

module Reek

  class Checker < SexpProcessor
    attr_accessor :description

    def initialize(smells)
      super()
      @require_empty = false
      @smells = smells
      @description = ''
      @unsupported -= [:cfunc]
    end

    def report(smell)
      @smells << smell
    end

    def check_source(code)
      check_parse_tree ParseTree.new.parse_tree_for_string(code)
    end

    def check_object(obj)
      check_parse_tree ParseTree.new.parse_tree(obj)
    end
    
    def to_s
      description
    end

    def check_parse_tree(sexp)
      sexp.each { |exp| process(exp) }
    end
  end
end
