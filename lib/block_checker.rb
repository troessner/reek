$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'parse_tree'
require 'sexp_processor'
require 'printer'

module Reek

  class BlockChecker < SexpProcessor
    attr_accessor :calls

    def initialize
      super
      @require_empty = false
      @calls = Hash.new(0)
      @problems = []
    end

    def check(code)
      sexp = ParseTree.new.parse_tree_for_string(code)
      return if sexp.length == 0
      sexp.each { |stmt| process(stmt) }
    end

    def process_call(exp)
      receiver = process(exp[1])
      @calls[receiver] += 1
      unless exp.length == 3 then process(exp[3]) end
      s(exp)
    end

    def process_fcall(exp)
      @calls[:self] += 1
      unless exp.length == 2 then process(exp[2]) end
      s(exp)
    end

#--- TODO --- finish moving process_args to here from reek.rb
    def process_args(exp)
      num_params = exp.length - 1
      num_params -= 1 if exp[-1][0] == :block rescue true       # yuk -- gotta be a better way!
      unless @current_method.nil?
        @bad_methods << [@current_method, num_params] if num_params >= 3
        @current_method = nil
      end
      s(exp)
    end

    def report
      problems.join('')
    end

    def problems
      result = []
      max = @calls.empty? ? 0 : @calls.values.max
      mine = @calls[:self]
      @calls.each_key do |rcv|
        if @calls[rcv] == max
          result << "could be moved to '#{Reek::Printer.new.print(rcv)}'" if @calls[rcv] == max
        end
      end if max > mine
      result
    end
  end
  
end