$:.unshift File.dirname(__FILE__)

require 'reek/code_context'
require 'reek/object_refs'

module Reek
  class MethodContext < CodeContext
    attr_reader :parameters, :local_variables, :instance_variables
    attr_reader :outer, :calls, :refs
    attr_reader :num_statements, :depends_on_self
    attr_accessor :name

    def initialize(outer, exp)
      super
      @parameters = []
      @local_variables = []
      @instance_variables = []
      @name = exp[1].to_s
      @num_statements = 0
      @calls = Hash.new(0)
      @refs = ObjectRefs.new
      @outer.record_method(@name)    # TODO: should be children of outer?
    end

    def count_statements(num)
      @num_statements += num
    end

    def has_parameter(sym)
      parameters.include?(sym)
    end
    
    def record_call_to(exp)
      @calls[exp] += 1
    end
    
    def record_depends_on_self
      @depends_on_self = true
    end

    def record_instance_variable(sym)
      @instance_variables << sym
    end

    def record_local_variable(sym)
      @local_variables << sym
    end

    def record_parameter(sym)
      @parameters << sym
    end

    def outer_name
      "#{@outer.outer_name}#{@name}/"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end

    def envious_receivers
      return [] if @name == 'initialize' or @refs.self_is_max?
      @refs.max_keys
    end
  end
end
