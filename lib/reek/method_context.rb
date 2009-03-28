require 'reek/name'
require 'reek/code_context'
require 'reek/object_refs'

module Reek
  class MethodContext < CodeContext
    attr_reader :parameters
    attr_reader :calls
    attr_reader :refs
    attr_reader :num_statements

    def initialize(outer, exp, record = true)
      super(outer, exp)
      @parameters = []
      @local_variables = []
      @name = Name.new(exp[1])
      @num_statements = 0
      @calls = Hash.new(0)
      @depends_on_self = false
      @refs = ObjectRefs.new
      @outer.record_method(@name)    # TODO: should be children of outer?
    end

    def count_statements(num)
      @num_statements += num
    end

    def depends_on_instance?
      @depends_on_self || is_overriding_method?(@name)
    end

    def has_parameter(sym)
      @parameters.include?(sym.to_s)
    end
    
    def record_call_to(exp)
      @calls[exp] += 1
      receiver, meth = exp[1..2]
      if receiver.nil?
        record_depends_on_self
      else
        case receiver[0]
        when :lvar
          @refs.record_ref(receiver) unless meth == :new
        when :ivar
          record_depends_on_self
          @refs.record_reference_to_self
        end
      end
    end
    
    def record_depends_on_self
      @depends_on_self = true
    end

    def record_local_variable(sym)
      @local_variables << Name.new(sym)
    end

    def self.is_block_arg?(param)
      Array === param and param[0] == :block
    end

    def record_parameter(param)
      @parameters << Name.new(param) unless MethodContext.is_block_arg?(param)
    end

    def outer_name
      "#{@outer.outer_name}#{@name}/"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end

    def envious_receivers
      return [] if @refs.self_is_max?
      @refs.max_keys
    end

    def variable_names
      @parameters + @local_variables
    end
  end
end
