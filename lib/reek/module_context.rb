require File.join( File.dirname( File.expand_path(__FILE__)), 'code_context')
require File.join( File.dirname( File.expand_path(__FILE__)), 'code_parser')
require File.join( File.dirname( File.expand_path(__FILE__)), 'sniffer')

module Reek

  #
  # A context wrapper for any module found in a syntax tree.
  #
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

    def parameterized_methods(min_clump_size)
      @parsed_methods.select {|meth| meth.parameters.length >= min_clump_size }
    end

    def record_method(meth)
      @parsed_methods << meth
    end
  end
end
