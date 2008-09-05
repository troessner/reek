$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'

module Reek

  class Printer < SexpProcessor
    def self.print(sexp)
      new.print(sexp)
    end

    def initialize
      super
      @require_empty = false
      @report = ''
    end

    def print(sexp)
      @report = sexp.inspect
      process(sexp)
      @report
    end

    def process_lvar(exp)
      @report = exp[1].inspect
      s(exp)
    end

    def process_dvar(exp)
      @report = exp[1].inspect
      s(exp)
    end

    def process_gvar(exp)
      @report = exp[1].inspect
      s(exp)
    end

    def process_const(exp)
      @report = exp[1].inspect
      s(exp)
    end

    def process_call(exp)
      @report = "#{exp[1]}.#{exp[2]}"
      @report += "(#{exp[3]})" if exp.length > 3
      s(exp)
    end
  end
  
end
