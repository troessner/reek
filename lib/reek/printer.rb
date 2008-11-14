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
      @default_method = :process_default
      @require_empty = @warn_on_default = false
      @report = ''
    end

    def print(sexp)
      @report = sexp.to_s
      return @report unless Array === sexp
      process(sexp)
      @report
    end

    def process_default(exp)
      @report = exp.inspect
      s(exp)
    end

    def process_array(exp)
      @report = Printer.print(exp[1])
      s(exp)
    end

    def process_lvar(exp)
      @report = exp[1].to_s
      s(exp)
    end

    def process_lit(exp)
      @report = exp[1].to_s
      s(exp)
    end

    def process_str(exp)
      @report = exp[1].inspect
      s(exp)
    end

    def process_xstr(exp)
      @report = "`#{exp[1]}`"
      s(exp)
    end

    def process_dvar(exp)
      @report = Printer.print(exp[1])
      s(exp)
    end

    def process_gvar(exp)
      @report = exp[1].to_s
      s(exp)
    end

    def process_ivar(exp)
      @report = exp[1].to_s
      s(exp)
    end

    def process_vcall(exp)
      meth, args = exp[1..2]
      @report = meth.to_s
      @report += "(#{Printer.print(args)})" if args
      s(exp)
    end

    def process_fcall(exp)
      process_vcall(exp)
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
      mod, member = exp[1..2]
      @report = "#{Printer.print(mod)}::#{Printer.print(member)}"
      s(exp)
    end

    def process_iter(exp)
      @report = 'block'
      s(exp)
    end

    def process_call(exp)
      receiver, meth, args = exp[1..3]
      @report = "#{Printer.print(receiver)}.#{meth}"
      @report += "(#{Printer.print(args)})" if args
      s(exp)
    end
  end
  
end
