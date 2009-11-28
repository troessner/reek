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

    def initialize(outer, name, exp)
      super(outer, exp)
      @name = name
      @scope_connector = '::'
      @parsed_methods = []
    end

    def myself
      @myself ||= @outer.find_module(@name)
    end

    def find_module(modname)
      return nil unless myself
      @myself.const_or_nil(modname.to_s)
    end

    def parameterized_methods(min_clump_size)
      @parsed_methods.select {|meth| meth.parameters.length >= min_clump_size }
    end

    def record_method(meth)
      @parsed_methods << meth
    end

    def variable_names
      []
    end
  end
end
