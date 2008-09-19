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
      @report = sexp.to_s
      return @report unless Array === sexp
      process(sexp)
      @report
    end

    def process_lvar(exp)
      @report = Printer.print(exp[1])
      s(exp)
    end

    def process_dvar(exp)
      @report = Printer.print(exp[1])
      s(exp)
    end

    def process_gvar(exp)
      @report = Printer.print(exp[1])
      s(exp)
    end

    def process_cvar(exp)
      @report = Printer.print(exp[1])
      s(exp)
    end

    def process_const(exp)
      @report = Printer.print(exp[1])
      s(exp)
    end
    
    def process_colon2(exp)
      @report = "#{Printer.print(exp[1])}::#{Printer.print(exp[2])}"
      s(exp)
    end

    def process_iter(exp)
      @report = 'block'
      s(exp)
    end

    def process_call(exp)
      @report = "#{exp[1]}.#{exp[2]}"
      @report += "(#{exp[3]})" if exp.length > 3
      s(exp)
    end
  end
  
end
