require 'set'
require 'reek/code_context'

class Class
  def is_overriding_method?(name)
    sym = name.to_sym
    mine = instance_methods(false)
    dads = superclass.instance_methods(true)
    (mine.include?(sym) and dads.include?(sym)) or (mine.include?(name) and dads.include?(name))
  end
end

module Reek
  class ClassContext < CodeContext

    def ClassContext.create(outer, exp)
      res = Name.resolve(exp[1], outer)
      ClassContext.new(res[0], res[1], exp[2])
    end

    def ClassContext.from_s(src)
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      CodeParser.new(sniffer).process_class(source.syntax_tree)
    end

    # SMELL: inconsistent with other contexts (not linked to the sexp)
    def initialize(outer, name, superclass = nil)
      super(outer, nil)
      @name = name
      @superclass = superclass
      @parsed_methods = []
      @instance_variables = Set.new
    end

    def myself
      @myself ||= @outer.find_module(@name)
    end

    def find_module(modname)
      return nil unless myself
      @myself.const_or_nil(modname.to_s)
    end

    def is_overriding_method?(name)
      return false unless myself
      @myself.is_overriding_method?(name.to_s)
    end
    
    def is_struct?
      @superclass == [:const, :Struct]
    end

    def num_methods
      @parsed_methods.length
    end

    def record_instance_variable(sym)
      @instance_variables << Name.new(sym)
    end

    def record_method(name)
      @parsed_methods << name.to_s
    end

    def outer_name
      "#{@outer.outer_name}#{@name}#"
    end

    def to_s
      "#{@outer.outer_name}#{@name}"
    end

    def variable_names
      @instance_variables
    end
  end
end
