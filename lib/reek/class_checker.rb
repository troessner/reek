$:.unshift File.dirname(__FILE__)

require 'reek/checker'
require 'reek/method_checker'

module Reek

  class ClassChecker < Checker

    def initialize(report)
      super(report)
      @description = ''
    end

    def process_class(exp)  # :nodoc:
      @description = exp[1].to_s
      superclass = exp[2]
      LargeClass.check(@description, self)
      exp[3..-1].each { |defn| process(defn) } unless superclass == [:const, :Struct]
      s(exp)
    end

    def process_defn(exp)  # :nodoc:
      bc = Reek::MethodChecker.new(@smells, @description)
      bc.process(exp)
      s(exp)
    end  
  end
end