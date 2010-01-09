require 'reek/name'
require 'reek/object_refs'

#
# Extensions to +Array+ needed by Reek.
#
class Array
  def power_set
    self.inject([[]]) { |cum, element| cum.cross(element) }
  end

  def bounded_power_set(lower_bound)
    power_set.select {|ps| ps.length > lower_bound}
  end

  def cross(element)
    result = []
    self.each do |set|
      result << set
      result << (set + [element])
    end
    result
  end

  def intersection
    self.inject { |res, elem| elem & res }
  end
end

module Reek

  #
  # The parameters in a method's definition.
  #
  module MethodParameters
    def default_assignments
      assignments = self[-1]
      result = {}
      return result unless is_assignment_block?(assignments)
      assignments[1..-1].each do |exp|
        result[exp[1]] = exp[2] if exp[0] == :lasgn
      end
      result
    end
    def is_arg?(param)
      return false if is_assignment_block?(param)
      return !(param.to_s =~ /^\&/)
    end
    def is_assignment_block?(param)
      Array === param and param[0] == :block
    end

    def names
      return @names if @names
      @names = self[1..-1].select {|arg| is_arg?(arg)}.map {|arg| Name.new(arg)}
    end

    def length
      names.length
    end

    def include?(name)
      names.include?(name)
    end
  end

  #
  # A context wrapper for any method definition found in a syntax tree.
  #
  class MethodContext < CodeContext
    attr_reader :parameters
    attr_reader :refs
    attr_reader :num_statements

    def initialize(outer, exp)
      super(outer, exp)
      @parameters = exp[exp[0] == :defn ? 2 : 3]  # SMELL: SimulatedPolymorphism
      @parameters ||= []
      @parameters.extend(MethodParameters)
      @name = Name.new(exp[1])
      @scope_connector = '#'
      @num_statements = 0
      @depends_on_self = false
      @refs = ObjectRefs.new
      @outer.record_method(self)    # SMELL: these could be found by tree walking
    end

    def count_statements(num)
      @num_statements += num
    end

    def depends_on_instance?
      @depends_on_self
    end

    def record_call_to(exp)
      record_receiver(exp)
    end

    def record_use_of_self
      record_depends_on_self
      @refs.record_reference_to_self
    end

    def record_instance_variable(sym)
      record_use_of_self
    end
    
    def record_depends_on_self
      @depends_on_self = true
    end

    def envious_receivers
      return [] if @refs.self_is_max?
      @refs.max_keys
    end

  private

    def record_receiver(exp)
      receiver, meth = exp[1..2]
      receiver ||= [:self]
      case receiver[0]
      when :lvar
        @refs.record_ref(receiver) unless meth == :new
      when :self
        record_use_of_self
      end
    end
  end
end
