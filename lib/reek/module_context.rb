require 'reek/code_context'
require 'reek/code_parser'
require 'reek/sniffer'

module Reek
  class ModuleContext < CodeContext

    class << self
      def create(outer, exp)
        res = Name.resolve(exp[1], outer)
        new(res[0], res[1], exp)
      end

      def from_s(src)
        source = src.to_reek_source
        sniffer = Sniffer.new(source)
        CodeParser.new(sniffer).do_module_or_class(source.syntax_tree, self)
      end
    end

    attr_reader :attributes

    def initialize(outer, name, exp)
      super(outer, exp)
      @name = name
      @attributes = Set.new
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
