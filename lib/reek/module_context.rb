require 'reek/code_context'

module Reek
  class ModuleContext < CodeContext

    def ModuleContext.create(outer, exp)
      res = Name.resolve(exp[1], outer)
      ModuleContext.new(res[0], res[1], exp)
    end

    def ModuleContext.from_s(src)
      source = src.to_reek_source
      sniffer = Sniffer.new(source)
      CodeParser.new(sniffer).process_module(source.syntax_tree)
    end

    attr_reader :class_variables, :attributes

    def initialize(outer, name, exp)
      super(outer, exp)
      @name = name
      @attributes = Set.new
      @class_variables = Set.new
    end

    def myself
      @myself ||= @outer.find_module(@name)
    end

    def find_module(modname)
      return nil unless myself
      @myself.const_or_nil(modname.to_s)
    end

    def record_attribute(attr)
      @attributes << Name.new(attr)
    end

    def record_class_variable(cvar)
      @class_variables << Name.new(cvar)
    end

    def check_for_attribute_declaration(exp)
      if [:attr, :attr_reader, :attr_writer, :attr_accessor].include? exp[2]
        exp[3][1..-1].each {|arg| record_attribute(arg[1])}
      end
    end

    def outer_name
      "#{@outer.outer_name}#{@name}::"
    end

    def variable_names
      []
    end
  end
end
